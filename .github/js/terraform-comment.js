module.exports = async ({ github, context }) => {
    const author = process.env.COMMENT_AUTHOR
    const title = process.env.COMMENT_TITLE

    const { data: comments } = await github.rest.issues.listComments({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: context.issue.number,
    })
    const label = `## terraform \`${title}\``
    const botComment = comments.find(comment => {
        return comment.user.type === 'Bot' && comment.body.includes(label)
    })

    let body = process.env.COMMENT_BODY
    if (body.includes('Your infrastructure matches the configuration')) {
        body = ''
    } else {
        const index = body.indexOf('Terraform used the selected providers')
        if (index >= 0) {
            body = body.slice(index)
        }
    }

    if (body.length > 80000) {
        body = '# Content is too long to include in GitHub comment'
    }

    const output = `${label}
  
  \`\`\`hcl
  ${body}
  \`\`\`
  
  @${author}`

    if (body != '') {
        if (botComment) {
            github.rest.issues.updateComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                comment_id: botComment.id,
                body: output
            })
        } else {
            github.rest.issues.createComment({
                issue_number: context.issue.number,
                owner: context.repo.owner,
                repo: context.repo.repo,
                body: output
            })
        }
    } else {
        if (botComment) {
            github.rest.issues.deleteComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                comment_id: botComment.id
            })
        }
    }
}