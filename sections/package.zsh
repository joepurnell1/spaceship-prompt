#
# Package
#
# Current package version.
# These package managers supported:
#   * NPM
#   * Cargo

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_PACKAGE_SHOW="${SPACESHIP_PACKAGE_SHOW=true}"
SPACESHIP_PACKAGE_PREFIX="${SPACESHIP_PACKAGE_PREFIX="use "}"
SPACESHIP_PACKAGE_SUFFIX="${SPACESHIP_PACKAGE_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_PACKAGE_SYMBOL="${SPACESHIP_PACKAGE_SYMBOL="📦 "}"
SPACESHIP_PACKAGE_COLOR="${SPACESHIP_PACKAGE_COLOR="red"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

spaceship_package() {
  [[ $SPACESHIP_PACKAGE_SHOW == false ]] && return

  # Show package version only when repository is a package
  local 'package_version'

  if [[ -f package.json ]] && spaceship::exists npm; then
    if spaceship::exists jq; then
      package_version=$(jq -r '.version' package.json 2>/dev/null)
    elif spaceship::exists python; then
      package_version=$(python -c "import json; print(json.load(open('package.json'))['version'])" 2>/dev/null)
    elif spaceship::exists node; then
      package_version=$(node -p "require('./package.json').version" 2> /dev/null)
    fi
  fi

  if [[ -f Cargo.toml ]] && spaceship::exists cargo; then
    # Handle missing field `version` in Cargo.toml.
    # `cargo pkgid` need Cargo.lock exists too. If it does't, do not show package version
    # https://github.com/denysdovhan/spaceship-prompt/pull/617
    local pkgid=$(cargo pkgid 2>&1)
    echo $pkgid | grep -q "error:" || package_version=${pkgid##*\#}
  fi

  if [[ -f package-lock.json ]]; then
    packager="npm"
  elif [[ -f yarn.lock ]]; then
    packager="yarn"
  elif [[ -f yarn.lock ]] && [[ -f package-lock.json ]]; then
    packager="both?"
  fi

  [[ -z $packager || "$packager" == "null" || "$packager" == "undefined" ]] && return
  # [[ -z $package_version || "$package_version" == "null" || "$package_version" == "undefined" ]] && return

  spaceship::section \
    "$SPACESHIP_PACKAGE_COLOR" \
    "$SPACESHIP_PACKAGE_PREFIX" \
    "${SPACESHIP_PACKAGE_SYMBOL} ${packager}" \
    "$SPACESHIP_PACKAGE_SUFFIX"
}
