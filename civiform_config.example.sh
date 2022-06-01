#! /usr/bin/env bash

# CiviForm deployment configuration file.
#
# Copy this file to civiform_config.sh in the same directory and edit the copy.
#
# cp civiform_config.example.sh civiform_config.sh
#
# Configuration variables must be specified in SCREAMING_SNAKE_CASE with the
# "export" keyword preceding them. All values must be quoted as strings. There
# should be no spaces before or after the equals sign.

#################################################
# Global variables for all CiviForm deployments
#################################################

# REQUIRED
# A supported CiviForm cloud provider, lower case.
export CIVIFORM_CLOUD_PROVIDER="azure"

# REQUIRED
# One of prod, staging, or dev.
export CIVIFORM_MODE="staging"

# REQUIRED
# The template directory for this deployment.
export TERRAFORM_TEMPLATE_DIR="cloud/azure/templates/azure_saml_ses"

# REQUIRED
# The short name for the civic entity. Ex. "Rochester"
export CIVIC_ENTITY_SHORT_NAME=""

# REQUIRED
# The full name for the civic entity. Ex. "City of Rochester"
export CIVIC_ENTITY_FULL_NAME=""

# REQUIRED
# The email address to contact for support with using Civiform. Ex. "Civiform@CityOfRochester.gov
export CIVIC_ENTITY_SUPPORT_EMAIL_ADDRESS=""

# REQUIRED
# A link to an image of the civic entity logo that includes the entity name, to be used in the header for the "Get Benefits" page
export CIVIC_ENTITY_LOGO_WITH_NAME_URL=""

# REQUIRED
# A link to an image of the civic entity logo, to be used on the login page
export CIVIC_ENTITY_SMALL_LOGO_URL=""

# REQUIRED
# The authentication protocl used for applicant and trusted intermediary accounts.
export CIVIFORM_APPLICANT_AUTH_PROTOCOL=""

# REQUIRED
# The name of the application in Azure App Service.
# The Azure public DNS entry for the app will prepend this value.
# Can only consist of lowercase letters and numbers, and must be between 3 and 24
# characters long.
export APPLICATION_NAME=""

# REQUIRED
# The docker repository name for retrieving server images.
export DOCKER_REPOSITORY_NAME="civiform"

# REQUIRED
# The docker user name for retrieving server images.
export DOCKER_USERNAME="civiform"

# REQUIRED
# The email address to use for the "from" field in emails sent from CiviForm.
export SENDER_EMAIL_ADDRESS=""

# REQUIRED
# The email address that receives a notifications email each time an applicant
# submits an application to a program in the staging environments, instead of
# sending it to the program administrator's email, as would happen in prod.
export STAGING_PROGRAM_ADMIN_NOTIFICATION_MAILING_LIST=""

# REQUIRED
# The email address that receives a notifications email each time an applicant
# submits an application to a program in the staging environments, instead of
# sending it to the trusted intermediary's email, as would happen in prod.
export STAGING_TI_NOTIFICATION_MAILING_LIST=""

# REQUIRED
# The email address that receives a notifications email each time an applicant
# submits an application to a program in the staging environments, instead of
# sending it to the applicant's email, as would happen in prod.
export STAGING_APPLICANT_NOTIFICATION_MAILING_LIST=""

# REQUIRED
# The custom domain name for this CiviForm deployment, not including the
# protocol. E.g. "civiform.seattle.gov"
export CUSTOM_HOSTNAME=""

# OPTIONAL
# The time zone to be used when rendering any times within the CiviForm
# UI. A list of valid time zone identifiers can be found at:
# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
export CIVIFORM_TIME_ZONE_ID="America/Los_Angeles"

#################################################
# Template variables for: azure_saml_ses
#################################################

# REQUIRED
# The Azure region to use, must be lower case.
# See https://azure.microsoft.com/en-us/global-infrastructure/geographies
export AZURE_LOCATION="eastus"

# REQUIRED
# The storage account name for the deployment log file (not the application
# server logs). Only letters and numbers allowed.
# e.g. "civiformdeploylogstorage"
export AZURE_LOG_STORAGE_ACCOUNT_NAME=""

# REQUIRED
# The Azure subscription ID for this deployment, used for billing.
export AZURE_SUBSCRIPTION=""

# REQUIRED
# The Azure resource group for this deployment.
export AZURE_RESOURCE_GROUP=""

# REQUIRED
# The AWS account username for sending emails with SES.
export AWS_USERNAME=""

# REQUIRED
# An Azure Storage Account name for storing the SAML keystore secrets.
# Only letters and numbers allowed.
# e.g. "civiformsamlkeystoresecrets"
export SAML_KEYSTORE_ACCOUNT_NAME=""

# REQUIRED
# The Azure key vault for storing application secrets.
# Only letters and numbers allowed.
# e.g. "civiformkeyvault"
export KEY_VAULT_NAME=""

# REQUIRED
# The ADFS group name for specifying CiviForm admins. If usinge
# Azure AD this is the group's object ID
export ADFS_ADMIN_GROUP=""

# REQUIRED
# API key for the LoginRadius application. Copy from the LoginRadius dashboard.
export LOGIN_RADIUS_API_KEY=""

# REQUIRED
# URI for retrieving LoginRadius metadata. Copy from the LoginRadius dashboard.
export LOGIN_RADIUS_METADATA_URI=""

# REQUIRED
# App name for CiviForm in LoginRadius. Copy from the LoginRadius dashboard.
export LOGIN_RADIUS_SAML_APP_NAME=""
