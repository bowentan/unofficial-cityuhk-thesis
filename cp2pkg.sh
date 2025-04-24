src=$1
dst=$2

if [ -z "$src" ] || [ -z "$dst" ]; then
  echo "Usage: $0 <source> <destination>"
  exit 1
fi

rsync -av \
  --exclude-from=<(git ls-files --others --ignored --exclude-standard --directory) \
  --exclude=".git" \
  --exclude=".gitignore" \
  --exclude="cp2pkg.sh" \
  $src $dst
