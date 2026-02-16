#!/usr/bin/env bash
# install_deps.sh - Cross-platform dependency installer for LaTeX document skill
#
# Source this file from other scripts:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "${SCRIPT_DIR}/install_deps.sh"
#
# Then call:
#   install_packages texlive poppler imagemagick pandoc
#
# Supported package managers: apt-get, brew, dnf, apk, pacman
# Logical package names: texlive, poppler, imagemagick, pandoc

# Avoid re-sourcing
if [[ -n "${_INSTALL_DEPS_LOADED:-}" ]]; then
  return 0 2>/dev/null || true
fi
_INSTALL_DEPS_LOADED=1

# --- Detect package manager ---
_detected_pkg_manager=""

detect_pkg_manager() {
  if [[ -n "$_detected_pkg_manager" ]]; then
    echo "$_detected_pkg_manager"
    return 0
  fi

  if command -v apt-get &>/dev/null; then
    _detected_pkg_manager="apt"
  elif command -v brew &>/dev/null; then
    _detected_pkg_manager="brew"
  elif command -v dnf &>/dev/null; then
    _detected_pkg_manager="dnf"
  elif command -v apk &>/dev/null; then
    _detected_pkg_manager="apk"
  elif command -v pacman &>/dev/null; then
    _detected_pkg_manager="pacman"
  else
    _detected_pkg_manager="unknown"
  fi

  echo "$_detected_pkg_manager"
}

# --- Run sudo if available, otherwise run directly ---
_run_privileged() {
  if command -v sudo &>/dev/null; then
    sudo "$@"
  else
    "$@"
  fi
}

# --- Low-level package install for detected manager ---
_apt_updated=false

run_pkg_install() {
  local mgr
  mgr="$(detect_pkg_manager)"
  local packages=("$@")

  if [[ ${#packages[@]} -eq 0 ]]; then
    return 0
  fi

  case "$mgr" in
    apt)
      if [[ "$_apt_updated" == false ]]; then
        echo ":: Updating apt package list..." >&2
        _run_privileged apt-get update -qq >&2 2>&1 || true
        _apt_updated=true
      fi
      echo ":: Installing (apt): ${packages[*]}" >&2
      DEBIAN_FRONTEND=noninteractive _run_privileged apt-get install -y -qq "${packages[@]}" >&2 2>&1
      ;;
    brew)
      echo ":: Installing (brew): ${packages[*]}" >&2
      for pkg in "${packages[@]}"; do
        if [[ "$pkg" == *"--cask"* ]]; then
          # Strip --cask marker and install as cask
          local cask_pkg="${pkg//--cask /}"
          brew install --cask "$cask_pkg" >&2 2>&1 || true
        else
          brew install "$pkg" >&2 2>&1 || true
        fi
      done
      ;;
    dnf)
      echo ":: Installing (dnf): ${packages[*]}" >&2
      _run_privileged dnf install -y "${packages[@]}" >&2 2>&1
      ;;
    apk)
      echo ":: Installing (apk): ${packages[*]}" >&2
      _run_privileged apk add --no-cache "${packages[@]}" >&2 2>&1
      ;;
    pacman)
      echo ":: Installing (pacman): ${packages[*]}" >&2
      _run_privileged pacman -S --noconfirm "${packages[@]}" >&2 2>&1
      ;;
    *)
      echo "Error: No supported package manager found." >&2
      echo "Please install the following packages manually:" >&2
      echo "  ${packages[*]}" >&2
      echo "" >&2
      echo "Platform-specific commands:" >&2
      echo "  Debian/Ubuntu:  sudo apt-get install ${packages[*]}" >&2
      echo "  macOS:          brew install ${packages[*]}" >&2
      echo "  Fedora/RHEL:    sudo dnf install ${packages[*]}" >&2
      echo "  Alpine:         sudo apk add ${packages[*]}" >&2
      echo "  Arch:           sudo pacman -S ${packages[*]}" >&2
      return 1
      ;;
  esac
}

# --- Map logical package names to platform-specific packages ---
_map_packages() {
  local logical_name="$1"
  local mgr
  mgr="$(detect_pkg_manager)"

  case "$logical_name" in
    texlive)
      case "$mgr" in
        apt)    echo "texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra texlive-latex-recommended texlive-science texlive-xetex texlive-luatex texlive-bibtex-extra biber" ;;
        brew)   echo "--cask basictex" ;;
        dnf)    echo "texlive-scheme-medium texlive-collection-science texlive-collection-xetex texlive-collection-luatex texlive-collection-bibtexextra biber" ;;
        apk)    echo "texlive-full biber" ;;
        pacman) echo "texlive-most biber" ;;
        *)      echo "texlive biber" ;;
      esac
      ;;
    poppler)
      case "$mgr" in
        apt)    echo "poppler-utils" ;;
        brew)   echo "poppler" ;;
        dnf)    echo "poppler-utils" ;;
        apk)    echo "poppler-utils" ;;
        pacman) echo "poppler" ;;
        *)      echo "poppler-utils" ;;
      esac
      ;;
    imagemagick)
      case "$mgr" in
        apt)    echo "imagemagick" ;;
        brew)   echo "imagemagick" ;;
        dnf)    echo "ImageMagick" ;;
        apk)    echo "imagemagick" ;;
        pacman) echo "imagemagick" ;;
        *)      echo "imagemagick" ;;
      esac
      ;;
    pandoc)
      case "$mgr" in
        apt)    echo "pandoc" ;;
        brew)   echo "pandoc" ;;
        dnf)    echo "pandoc" ;;
        apk)    echo "pandoc" ;;
        pacman) echo "pandoc" ;;
        *)      echo "pandoc" ;;
      esac
      ;;
    *)
      echo "Warning: Unknown logical package '$logical_name'" >&2
      echo "$logical_name"
      ;;
  esac
}

# --- Public API: install packages by logical name ---
install_packages() {
  local all_packages=()

  for logical_name in "$@"; do
    local mapped
    mapped="$(_map_packages "$logical_name")"
    # Split mapped string into array elements
    read -ra pkgs <<< "$mapped"
    all_packages+=("${pkgs[@]}")
  done

  if [[ ${#all_packages[@]} -eq 0 ]]; then
    return 0
  fi

  # Remove duplicates while preserving order
  local unique_packages=()
  local seen=""
  for pkg in "${all_packages[@]}"; do
    if [[ ! " $seen " =~ " $pkg " ]]; then
      unique_packages+=("$pkg")
      seen="$seen $pkg"
    fi
  done

  run_pkg_install "${unique_packages[@]}"
}

# --- Brew post-install: update PATH for basictex ---
_brew_post_texlive() {
  local mgr
  mgr="$(detect_pkg_manager)"
  if [[ "$mgr" == "brew" ]]; then
    # basictex installs to /Library/TeX/texbin
    if [[ -d "/Library/TeX/texbin" ]] && [[ ! "$PATH" =~ "/Library/TeX/texbin" ]]; then
      export PATH="/Library/TeX/texbin:$PATH"
      echo ":: Added /Library/TeX/texbin to PATH" >&2
    fi
  fi
}

# --- Helper: print manual install instructions for a logical package ---
print_install_help() {
  local logical_name="$1"
  echo "" >&2
  echo "Install '$logical_name' manually:" >&2
  echo "  Debian/Ubuntu:  sudo apt-get install $(_map_packages "$logical_name")" >&2

  # Temporarily override manager for each platform's instructions
  local orig="$_detected_pkg_manager"

  _detected_pkg_manager="brew"
  echo "  macOS:          brew install $(_map_packages "$logical_name")" >&2

  _detected_pkg_manager="dnf"
  echo "  Fedora/RHEL:    sudo dnf install $(_map_packages "$logical_name")" >&2

  _detected_pkg_manager="apk"
  echo "  Alpine:         sudo apk add $(_map_packages "$logical_name")" >&2

  _detected_pkg_manager="pacman"
  echo "  Arch:           sudo pacman -S $(_map_packages "$logical_name")" >&2

  _detected_pkg_manager="$orig"
  echo "" >&2
}
