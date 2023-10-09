#!/bin/sh
set -e

if [[ $REPO_HOST == "" ]]; then
   REPO_HOST=localhost
fi

if [[ $REPO_PORT == "" ]]; then
   REPO_PORT=8080
fi

if [[ $REPO_CONTEXT == "" ]]; then
   REPO_CONTEXT=alfresco
fi

if [[ $TIMEOUT == "" ]]; then
   TIMEOUT=300s
fi

if [[ $WAIT_RETRY_INTERVAL == "" ]]; then
   WAIT_RETRY_INTERVAL=5s
fi

echo "Replace 'REPO_HOST' with '$REPO_HOST' and 'REPO_PORT' with '$REPO_PORT'"

sed -i -e 's/REPO_HOST:REPO_PORT/'"$REPO_HOST:$REPO_PORT"'/g' /opt/tomcat8/shared/classes/alfresco/web-extension/share-config-custom.xml

if [[ $KERBEROS_ENABLED == "true" ]]; then
   sed -i -e 's/condition="KerberosDisabled"/condition="Kerberos"/g' /opt/tomcat8/shared/classes/alfresco/web-extension/share-config-custom.xml
   sed -i -e 's/KERBEROS_SECRET/'"$KERBEROS_SECRET"'/g' /opt/tomcat8/shared/classes/alfresco/web-extension/share-config-custom.xml
   sed -i -e 's/KERBEROS_REALM/'"$KERBEROS_REALM"'/g' /opt/tomcat8/shared/classes/alfresco/web-extension/share-config-custom.xml
   sed -i -e 's/KERBEROS_SPN/'"$KERBEROS_SPN"'/g' /opt/tomcat8/shared/classes/alfresco/web-extension/share-config-custom.xml
   sed -i -e '/IF_KERBEROS_ENABLED/d' /opt/tomcat8/shared/classes/alfresco/web-extension/share-config-custom.xml
   sed -i -e 's/KERBEROS_KEYTAB/'"$KERBEROS_KEYTAB"'/g' $JAVA_HOME/conf/security/java.login.config
   sed -i -e 's/KERBEROS_PRINCIPAN/'"$KERBEROS_PRINCIPAN"'/g' $JAVA_HOME/conf/security/java.login.config
else   
   KERBEROS_ENABLED="false"
fi
#Если файл с переменными средами из Hashicorp Vault существует, то он их запишет в контейнер
if [[ -f /vault/secrets/config ]]; then
source /vault/secrets/config
fi
####
bash -c "$@"