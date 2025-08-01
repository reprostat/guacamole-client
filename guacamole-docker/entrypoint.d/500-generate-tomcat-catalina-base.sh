#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

##
## 500-generate-tomcat-catalina-base.sh
##
## Automcatically generates a fresh, temporary CATALINA_BASE for Apache Tomcat.
## This allows Tomcat to run as a reduced-privilege user, and allows its
## configuration to be dynamically generated by the container entrypoint at
## startup.
##

#
# Start with a fresh CATALINA_BASE
#

if [[ -z "$APACHE_BASE" ]]; then
    # If APACHE_BASE is not set, use a temporary directory for CATALINA_BASE
    rm -rf /tmp/catalina-base.*
    export CATALINA_BASE="`mktemp -p /tmp -d catalina-base.XXXXXXXXXX`"
else
    # If APACHE_BASE is set, CATALINA_BASE = APACHE_BASE/catalina-base    
    # - ensure APACHE_BASE is a directory
    if [[ -e "$APACHE_BASE" && ! -d "$APACHE_BASE" ]]; then
        echo "Error: APACHE_BASE must be a directory." >&2
        exit 1
    fi
    export CATALINA_BASE="$APACHE_BASE/catalina-base"
    # If CATALINA_BASE does not exists, create it
    if [[ ! -d "$CATALINA_BASE" ]]; then
        mkdir -p "$CATALINA_BASE"
    fi
fi
echo "Using CATALINA_BASE: $CATALINA_BASE"

# User-only writable CATALINA_BASE
for dir in logs temp webapps work; do
    mkdir -p $CATALINA_BASE/$dir
done
cp -R /usr/local/tomcat/conf $CATALINA_BASE

cat >> "$CATALINA_BASE/conf/catalina.properties" <<EOF

# Point Guacamole at automatically-generated, temporary GUACAMOLE_HOME
guacamole.home=$GUACAMOLE_HOME
EOF

# Install webapp
ln -sf /opt/guacamole/webapp/guacamole.war $CATALINA_BASE/webapps/${WEBAPP_CONTEXT:-guacamole}.war

