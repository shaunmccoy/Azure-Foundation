Role Name
=========

Creates Azure Devops Agent for running the devops pipeline

Requirements
------------
N/A

Dependencies
------------
N/A

Role Variables
--------------
```yaml
---
# vars file for azure_devops_agent
    
#Working directory where machine will be configured and agent will be installed
WORK_DIR: /tmp/agent_config

# Project that the Agent will run under
PROJECT_URL: https://dev.azure.com/PCET-SRE

#Source install scripts from microsoft
CONFIG_URL: https://vstsagentpackage.azureedge.net/agent/2.160.1/vsts-agent-linux-x64-2.160.1.tar.gz

# User token that machine will use to authenticate first time.
TOKEN: notmyrealauthtokenbutthiswillbeimported

# Pool that VM will be listed under
POOL: default

# Working directory for runs
AZ_WORK: _work

# Agent name as it will appear in portal. Default will resolve as the machine's hostname
AGENT_NAME: default

# HTTP Proxy server required to configure agent when on the internal network
PROXY_SERVER: http://proxy.example.com:80
```

Dependencies
------------
N/A


Author Information
------------------
email: owner@example.com

backup: backup@example.com