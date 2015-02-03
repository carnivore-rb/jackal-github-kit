# Jackal GitHub Kit

Provides communications interface with GitHub.

## Supported communications

* Repository commit comment
* Repository status

## Configuration

Access tokens are used for access to GitHub. Configuration can
be provided via direct configuration:

```json
{
  "jackal": {
    "github_kit": {
      "config": {
        "github": {
          "access_token": TOKEN
        }
      }
    }
  }
}
```

or it can be provided via application level configuration:

```json
{
  "jackal": {
    "github": {
      "access_token": ACCESS_TOKEN
    }
  }
}
```

## Payload structure

### Repository commit comment

```json
{
  ...
  "data": {
    "github_kit": {
      "commit_comment": {
        "repository": REPOSITORY_FULL_NAME,
        "reference": COMMIT_SHA,
        "message": MESSAGE_TEXT
      }
    }
  }
  ...
}
```

### Repository status

```json
{
  ...
  "data": {
    "github_kit": {
      "status": {
        "repository": REPOSITORY_FULL_NAME,
        "reference": COMMIT_SHA,
        "state": STATE,
        "extras": {
          "description": DESCRIPTION_TEXT,
          "target_url": STATUS_URL
        }
      }
    }
  }
  ...
}
```

# Info

* Repository: https://github.com/carnivore-rb/jackal-github-kit
* IRC: Freenode @ #carnivore
