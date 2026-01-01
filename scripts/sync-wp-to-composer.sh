set -euo pipefail

# List installed plugins (slug and version)
PLUGINS_JSON=$(docker compose exec -T web vendor/bin/wp plugin list --format=json)
THEMES_JSON=$(docker compose exec -T web vendor/bin/wp theme list --format=json)

echo "Generating composer requires from wp-admin installs..."

# Plugins
echo "$PLUGINS_JSON" | jq -r '.[] | "\(.name)@\(.version)"' | while read -r line; do
  slug="${line%@*}"
  ver="${line#*@}"
  # Try wpackagist first
  if composer show "wpackagist-plugin/${slug}" >/dev/null 2>&1; then
    echo "composer require wpackagist-plugin/${slug}:${ver}"
    composer require "wpackagist-plugin/${slug}:${ver}" --no-interaction
  else
    echo "• Plugin ${slug} not on WPackagist. Add a private/VCS/ZIP repository entry."
  fi
done

# Themes
echo "$THEMES_JSON" | jq -r '.[] | "\(.name)@\(.version)"' | while read -r line; do
  slug="${line%@*}"
  ver="${line#*@}"
  if composer show "wpackagist-theme/${slug}" >/dev/null 2>&1; then
    echo "composer require wpackagist-theme/${slug}:${ver}"
    composer require "wpackagist-theme/${slug}:${ver}" --no-interaction
  else
    echo "• Theme ${slug} not on WPackagist. Track as custom theme or add a repository."
  fi
done

echo "Done. Review composer.json/composer.lock and commit."
