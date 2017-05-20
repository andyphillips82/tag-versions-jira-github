now=$(date +'%m.%d.%Y')
projectname='Your Project Here'


iterate_tagname() {
## if second parameter exists, that means tag already exists
if [ -n "$2" ]
then
	tag=$1-$2
else
## second parameter doesn't exist.  initial run of the script.
	tag=$1
	i=0
fi

## check if tag exists
if git rev-parse $tag.. >/dev/null
then
	## it does exist?  iterate and run the function again
	i=$(($2+1))
	iterate_tagname $1 $i
else 
	## Does exist. Get the last tag, create the current tag, do a comparison to get commits.
	prevtag=$(git describe --abbrev=0 --tags)
	git tag $tag
	commits=$(git log --pretty=format:"%s" $prevtag..$tag)

	if [ -n "$commits" ]
	then
		## create versions in JIRA that match the tag #
		cd ../
		./jira.sh --action addVersion --project $projectname --name $tag --description ""	

		#loop through commits and find Pull Requests.  Parse string and get branch name.
		printf '%s\n' "$commits" | while IFS= read -r line
		do
		   if [[ $line == *"Merge pull request"* ]]; then
		   		branch=$(cut -d "/" -f 2 <<< "$line")
		   		#echo $branch
		   		./jira.sh --action updateIssue --issue $branch --fixVersions $tag
			fi
		done
		git push origin $tag
	else
		git tag -d $tag
	fi
fi
}

git fetch --tags
iterate_tagname $now