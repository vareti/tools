package main

import (
	"context"
	"fmt"
	"github.com/google/go-github/v31/github"
	"time"
)

func main() {
	ctx := context.Background()

	gitClient := github.NewClient(nil)

	issues, resp, err := gitClient.Issues.ListByRepo(ctx,
		"kubernetes",
		"kubernetes",
		&github.IssueListByRepoOptions{
			Labels: []string{"good first issue"},
			Assignee: "none",
			Since: time.Now().AddDate(0, 0, -7),
		})
	if err != nil {
		fmt.Printf("%v", err)
		return
	}

	if resp == nil {
		fmt.Printf("response is empty")
		return
	}

	fmt.Printf("Response is %+v\n", resp)

	for _, issue := range issues {
		fmt.Printf("%v\n\n", *issue.Title)
	}

}
