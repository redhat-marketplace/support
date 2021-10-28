# Red Hat Marketplace support scripts
A collection of scripts that enables you to gather diagnostic information from your openshift cluster that is most likely needed by [Red Hat Marketplace](https://marketplace.redhat.com/) support for debugging issues.


## Scripts
1. [rhm_operator_dump.sh](https://github.com/redhat-marketplace/support/blob/main/scripts/rhm_operator_dump.sh): This helps troubleshooting issues with Red Hat Marketplace operator installation and cluster registration. 

2. [rhm_metering_dump.sh](https://github.com/redhat-marketplace/support/blob/main/scripts/rhm_metering_dump.sh): This helps troubleshooting issues with Red Hat Marketplace operator's usage and metering.

#### Pre-requisites:
1. Valid login session to your OpenShift cluster
2. oc CLI in your PATH
3. Assign execute permissions to the script (`chmod +x ~/rhm_operator_dump.sh` or `chmod +x ~/rhm_metering_dump.sh`)

#### Download scripts directly to openshift cluster
  - curl https://github.com/redhat-marketplace/support/blob/main/scripts/rhm_operator_dump.sh --output /tmp/rhm_operator_dump.sh
  - curl https://github.com/redhat-marketplace/support/blob/main/scripts/rhm_metering_dump.sh --output /tmp/rhm_metering_dump.sh

#### Usage examples:
  - ./rhm_operator_dump.sh > operator_dump.txt
  - ./rhm_metering_dump.sh > metering_dump.txt

## Development

Long-term discussions and bug reports are maintained via GitHub Issues. Code review is done via GitHub Pull Requests.

Pull Requests should clearly describe two things:
1. The problem they attempt to solve
2. How the author went about solving the problem

Please run shellcheck before creating a pull request
https://github.com/koalaman/shellcheck


## Resources

  - Documentation
https://marketplace.redhat.com/en-us/documentation
  - Blogs
https://marketplace.redhat.com/en-us/blog/
  - Support
https://marketplace.redhat.com/en-us/support
