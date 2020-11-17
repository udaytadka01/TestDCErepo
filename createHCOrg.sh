#!/bin/bash

# Create scratch org
sfdx force:org:create -f config/project-scratch-def.json -a HCScratchOrg --setdefaultusername -d 30

# Install Health Cloud package (updated 10/26/2020)
# Latest at: https://industries.secure.force.com/healthcloud/
sfdx force:package:install --package 04t4W000002Aw8TQAS

# Install any extensions here:

# Push source code 
sfdx force:source:push -f -w 20

# Assign the permissions
sfdx force:user:permset:assign -n HealthCloudPermissionSetLicense
sfdx force:user:permset:assign -n HealthCloudAdmin
sfdx force:user:permset:assign -n HealthCloudApi
sfdx force:user:permset:assign -n HealthCloudFoundation
sfdx force:user:permset:assign -n HealthCloudLimited
sfdx force:user:permset:assign -n HealthCloudMemberServices
sfdx force:user:permset:assign -n HealthCloudSocialDeterminants
sfdx force:user:permset:assign -n HealthCloudStandard
sfdx force:user:permset:assign -n HealthCloudUtilizationManagement

# Create users here:

# Create data here:
# TODO: sfdx force:apex:execute -f config/create-data-setup.apex

#Open up org:
sfdx force:org:open