all:	git

git:
	git add .
	git commit -a
	git pull
	git push -u origin master
	exit
