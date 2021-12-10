#!/usr/bin/env bash

################################################################################################################################################
## Description:
##   This script collects OC objects, logs and other metadata from the objects corresponding to Red Hat Marketplace Operator.
##   This helps troubleshooting issues with Red Hat Marketplace operator installation and cluster registration.
##   NOTE: secrets data are NOT collected
##
## Pre-requisites:
##   1. Valid login session to your OpenShift cluster
##   2. oc CLI in your PATH
##
## Example:
##   ./rhm_operator_dump.sh > output.txt
################################################################################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m'
requiredVersion="^.*4\.([5-9]|[1-9][0-9])\.([1-9]?[0-9]).*$"
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

function errorExit() {
  echoRed "\n[ERROR] $1\n"
  exit 1
}

function checkOCInstalled() {
  if ! [ -x "$(command -v oc)" ]; then
    echoRed "[ERROR]: Pre-requisite cli 'oc' is not installed\n"
    exit 1
  fi
}

function testConnection() {
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

function checkRHMOperator() {
  oc get ns $NAMESPACE 2> /dev/null || errorExit "Namespace $NAMESPACE not found! Follow these steps to register the cluster with RHM: https://marketplace.redhat.com/en-us/workspace/clusters/add/register"
}

function displayHeading() {
  echo -e "\n\n============================================================================"
  echoBlue "${*}"
  echo "============================================================================"
}


testConnection

displayHeading 'Checking jq version'
jq --version 2> /dev/null || errorExit "[ERROR] Pre-requisite cli 'jq' is not installed\n"

checkOCCliVersion
checkOCServerVersion

displayHeading "Getting OpenShift server and client version"
oc version

displayHeading "Verifying if ${NAMESPACE} namespace already exists"
checkRHMOperator

displayHeading "Getting subscriptions in namespace ${NAMESPACE}"
oc get sub -n $NAMESPACE

displayHeading "Getting cluster service version (CSV) in namespace ${NAMESPACE}"
oc get csv -n $NAMESPACE

displayHeading "Getting catalog sources"
oc get catalogsources -n openshift-marketplace

displayHeading "Getting package manifest redhat-marketplace-operator"
oc get packagemanifests | grep redhat-marketplace-operator

displayHeading "Getting install plans in namespace ${NAMESPACE}"
oc get installplans -n $NAMESPACE

displayHeading "Getting all pods in namespace ${NAMESPACE}"
oc get pods -n $NAMESPACE

for POD in $(oc get pods -n $NAMESPACE --output json | jq '.items[] | .metadata.name' | sed 's/"//g')
do
  if [[ "${POD}" == "redhat-marketplace-controller-manager"* ]] || [[ "${POD}" == "rhm-watch-keeper"* ]]; then
    displayHeading "Describing pod ${POD}"
    oc describe pod "$POD" -n "$NAMESPACE"
    displayHeading "Logs from the pod ${POD}"
    oc logs "${POD}" -n "${NAMESPACE}" --all-containers --tail=500
  fi;
done

displayHeading 'Describing Red Hat Marketplace operator CSV'
for CSV in $(oc get csv -n $NAMESPACE --output json | jq '.items[] | .metadata.name' | sed 's/"//g')
do
  oc describe csv "$CSV" -n $NAMESPACE
done

displayHeading "Getting Remoteresources3s in namespace $NAMESPACE"
oc get remoteresources3s -n $NAMESPACE

displayHeading "Describing Remoteresources3 parent"
oc describe remoteresources3 parent  -n $NAMESPACE

displayHeading "Describing Remoteresources3 child"
oc describe remoteresources3 child  -n $NAMESPACE

displayHeading "Getting MarketplaceConfig in namespace $NAMESPACE"
oc get marketplaceconfig -n $NAMESPACE -o=yaml

displayHeading "Getting Services in namespace $NAMESPACE"
oc get service -n $NAMESPACE

displayHeading "Getting Routes in namespace $NAMESPACE"
oc get route -n $NAMESPACE

displayHeading "Getting datactl configuration"
FILE=$HOME/.datactl/config
if [ -f "$FILE" ]; then
    sed -e '/^  pull-secret-data:/ d' -e '/^  token-data:/ d' $FILE
fi
