# Share Your README Score

Ready to check your repo's README health? Here's how:

## 1. Install the Action

```sh
# Add to your .github/workflows/README-validate.yml
uses: readme-val/readme-validator@v1
with:
  repo: owner/repo
  threshold: 7
```

## 2. Check Your Repo

```sh
# GitHub Actions will post the score as a comment
# Or run locally:
bash -c '
  REPO="owner/repo"
  # ... scoring logic from readme-val
'
```

## 2. Share Your Score

Post this on social media:

```
My README scored 7/10 on @readme_val health check 📊

What did yours score? 👇

#ReadmeValidation #DevTools #SoftwareQuality
```

## 3. Sample Post Texts

**Twitter/LinkedIn:**
"🚀 Just validated my README with the new @readme_val GitHub Action and scored 7/10! The action checks title, badges, license, contributing guidelines & more. Install it in one line: `uses: readme-val/readme-validator@v1`. #DevTools #SoftwareQuality

**Twitter (short):**
"My README scored 7/10 — can yours beat it? 📊 @readme_val #CodeQuality #SoftwareEngineering"

**Reddit (r/programming):**
"Built a GitHub Action that validates README quality and scores 0-10. curious to see everyone's scores! https://github.com/mramitdas/readme-val"

## 4. Add to Your Repo

```yaml
# .github/workflows/README-validate.yml
name: README Validator
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: readme-val/readme-validator@v1
        with:
          repo: ${{ github.repository }}
          threshold: 7
```
