# Copyright © 2018 Software AG, Darmstadt, Germany and/or its licensors
#
# SPDX-License-Identifier: Apache-2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

#!/bin/bash

WD=$(cd "$(dirname "$0")";pwd)

if [ -z "$TC_HOME" ]; then
  echo "Please initialize the environment variable TC_HOME to the location of your extracted TerracottaDB kit"
  exit 1
fi

if [ -z "$TC_TCTQL_HOME" ]; then
  echo "Please initialize the environment variable TC_TCTQL_HOME to the location of your extracted TerracottaDB TCTQL kit"
  exit 1
fi

if [ ! -d "${JAVA_HOME}" ]; then
  echo "$0: the JAVA_HOME environment variable is not defined correctly"
  exit 2
fi

JAVA="${JAVA_HOME}/bin/java"
JAVAC="${JAVA_HOME}/bin/javac"

uname | grep CYGWIN > /dev/null && TC_HOME=$(cygpath -w -p "${TC_HOME}")

TC_CP=.
# Add the client jars in the classpath
find "${TC_HOME}/client/" -type f -name "*.jar" > file
find "${TC_TCTQL_HOME}/" -type f -name "*.jar" >> file
while IFS= read -r line; do
	TC_CP=${TC_CP}:${line}
done < file
rm file

# Add the logback configuration to the classpath
TC_CP=${TC_CP}:${TC_HOME}/client/logging/impl

echo "Compiling the sample class.."
"$JAVAC" -classpath "${TC_CP}" "${WD}/src/StoreTextualQuerying.java"

echo "Starting the TC DB sample client, it's going to try to connect to your local server..."
"$JAVA" -Xmx200m -classpath "$TC_CP:$WD/src/" StoreTextualQuerying
