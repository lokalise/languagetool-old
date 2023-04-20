#!/usr/bin/env bash

# Checking if NEWRELIC should be started alongside the app
if [[ ${IS_NEWRELIC_ENABLED} == "true" ]]; then
    echo "Enabling Newrelic..."
    JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS} -javaagent:/srv/newrelic/newrelic.jar -Dnewrelic.config.license_key=${NEWRELIC_LICENSE_KEY} -Dnewrelic.config.app_name='Language tool'"
fi

java -cp languagetool-server.jar org.languagetool.server.HTTPServer \
     --public \
     --port 8010 \
     --config server.properties


