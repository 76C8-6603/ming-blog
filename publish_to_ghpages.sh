echo "push all changes"
git config remote.origin.url https://github.com/76C8-6603/ming-blog.git
git add .
git commit -m "New Articles"
git push --all git@github.com:76C8-6603/ming-blog.git
if [ "`git status -s`" ]
then
	    echo "The working directory is dirty. Please commit any pending changes."
	        exit 1;
	fi

	echo "Deleting old publication"
	rm -rf public
	mkdir public
	git worktree prune
	rm -rf .git/worktrees/public/

	echo "Checking out gh-pages branch into public"
	git worktree add -B gh-pages public origin/gh-pages

	echo "Removing existing files"
	rm -rf public/*

	echo "Generating site"
	hugo

	echo "Updating gh-pages branch"
	cd public && git add --all && git commit -m "Publishing to gh-pages (publish.sh)"

	echo "Pushing to github"
	git push --all git@github.com:76C8-6603/ming-blog.git
