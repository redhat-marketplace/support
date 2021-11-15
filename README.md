# Red Hat Marketplace support scripts
A collection of scripts that enable you to gather diagnostic information from your OpenShift cluster for use by [Red Hat Marketplace](https://marketplace.redhat.com/) support for debugging issues.


## Scripts
| Script | Purpose |
|--------|---------|
|[rhm_operator_dump.sh](https://github.com/redhat-marketplace/support/blob/main/scripts/rhm_operator_dump.sh) | Troubleshooting issues with Red Hat Marketplace operator installation and cluster registration
|[rhm_metering_dump.sh](https://github.com/redhat-marketplace/support/blob/main/scripts/rhm_metering_dump.sh) | Troubleshooting issues with Red Hat Marketplace operator's usage and metering.

#### Pre-requisites
1. Valid login session to your OpenShift cluster (`oc login`)
2. `oc` CLI in your PATH (`export PATH=$PATH:/path/to/oc/binary`)
3. Assign execute permissions to the script (`chmod +x ./rhm_operator_dump.sh`, `chmod +x ./rhm_metering_dump.sh`)

#### Download scripts
The following commands will save the scripts in your current working directory.

```bash
  curl -L https://raw.githubusercontent.com/redhat-marketplace/support/blob/main/scripts/rhm_operator_dump.sh --output rhm_operator_dump.sh
  curl -L https://raw.githubusercontent.com/redhat-marketplace/support/blob/main/scripts/rhm_metering_dump.sh --output rhm_metering_dump.sh
```

#### Make scripts executable
```bash
  chmod +x ./rhm_operator_dump.sh
  chmod +x ./rhm_metering_dump.sh 
```

#### Usage examples
```bash
  ./rhm_operator_dump.sh > operator_dump.txt
  ./rhm_metering_dump.sh > metering_dump.txt
```

## Development

Long-term discussions and bug reports are maintained via GitHub Issues. Code review is done via GitHub Pull Requests.

Pull Requests should clearly describe two things:
1. The problem they attempt to solve
2. How the author went about solving the problem

Please run [`shellcheck`](https://github.com/koalaman/shellcheck) before creating a pull request.

## Resources
  - [Documentation](https://marketplace.redhat.com/en-us/documentation)
  - [Blogs](https://marketplace.redhat.com/en-us/blog/)
  - [Support](https://marketplace.redhat.com/en-us/support)
