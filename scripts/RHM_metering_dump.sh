#!/usr/bin/env bash


################################################################################################################################################
##Description:
##    This script collects OC objects, logs and other metadata from the objects corresponding to Red Hat Marketplace Operator.
##    This helps troubleshooting issues with Red Hat Marketplace operators usage and metering.
##.   NOTE: secrets data are NOT collected

## Pre-requisites:
##	1. Valid login session to your Openshift cluster
##	2. oc CLI in your PATH
##	3. RHM operator installed successfully.


## Example:
##	./RHM_metering_support_dump.sh > output.txt
################################################################################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m'
requiredVersion="^.*4\.([0-9]{2,}|[5-9]?)?(\.[0-9]+.*)*$"
NAMESPACE=openshift-redhat-marketplace




function echoGreen() {
  echo -e "${GREEN}$1${NC}"
}
 
function echoRed() {
  echo -e "${RED}$1${NC}"
}

function echoBlue() {
  echo -e "${BLUE}$1${NC}"
}

function echoYellow() {
  echo -e "${YELLOW}$1${NC}"
}



function errorExit () {
    echoRed "\n[ERROR] $1\n"
    exit 1
}


function checkOCInstalled() {
  if ! [ -x "$(command -v oc)" ]; then
      echoRed "[ERROR]: Pre-requisite cli 'oc' is not installed\n"
      exit 1
  fi
}
 

function testconnection() {
oc cluster-info > /dev/null 2>&1 || errorExit "Connection to cluster failed!"
}


function checkOCCliVersion() {
  result=$(oc version -o json 2>&1)
  RETVAL=$?
  if [ $RETVAL -gt 0 ]; then
    echoRed "Error checking oc cli installation. $result"
    exit $RETVAL
  fi
}

function checkOCServerVersion() {
  currentServerVersion="$(oc version -o json | jq .openshiftVersion)"
  if ! [[ $currentServerVersion =~ $requiredVersion ]]; then
    echoRed "Unsupported OpenShift version $currentServerVersion detected. Supported OpenShift versions are 4.5 and higher."
    exit 1
  fi
}


function checkrhmoperator() {
oc get ns $NAMESPACE 2> /dev/null || errorExit "Namespace $NAMESPACE not found! Follow these steps to register the cluster with RHM: https://marketplace.redhat.com/en-us/workspace/clusters/add/register"
}



function displayHeading() {
  echo -e "\n\n============================================================================"
  echoBlue "${*}"
  echo "============================================================================"
}




testconnection

checkOCCliVersion
checkOCServerVersion

displayheading "Getting openshift server and client version"
oc version

displayheading "Verifying if ${NAMESPACE} namespace already exists"
checkrhmoperator

displayheading "Status of all pods in ${NAMESPACE}"
oc get pods -n openshift-redhat-marketplace 

displayheading 'Status of MeterReports'
oc get meterreports -A

displayheading 'Status of MeterDefinitions'
oc get meterdefinitions -A

for POD in `oc get pods -n openshift-redhat-marketplace --output json | jq '.items[] | .metadata.name' | sed 's/"//g'`
do
  if [[ "${POD}" == "rhm-metric-state"* ]]; then
    displayheading "Describing pod ${POD}"
    oc describe pod ${POD} -n ${NAMESPACE}
    displayheading "Logs from the pod ${POD}"
    oc logs ${POD} -n ${NAMESPACE} --all-containers --tail=500
  elif [[ "${POD}" == "rhm-remoteresources3-controller"* ]]; then
    displayheading "Describing pod ${POD}"
    oc describe pod ${POD} -n ${NAMESPACE}
    displayheading "Logs from the pod ${POD}"
    oc logs ${POD} -n ${NAMESPACE} --all-containers --tail=500
  elif [[ "${POD}" == "meter-report-$(date '+%Y-%m-%d')"* ]]; then
    displayheading "Describing pod ${POD}"
    oc describe pod ${POD} -n ${NAMESPACE}
    displayheading "Logs from the pod ${POD}"
    oc logs ${POD} -n ${NAMESPACE} --all-containers --tail=500
  elif [[ "${POD}" == "meter-report-$(date +%Y-%m-%d -d "yesterday")"* ]]; then
    displayheading "Describing pod ${POD}"
    oc describe pod ${POD} -n ${NAMESPACE}
    displayheading "Logs from the pod ${POD}"
    oc logs ${POD} -n ${NAMESPACE} --all-containers --tail=500
  fi;
done

