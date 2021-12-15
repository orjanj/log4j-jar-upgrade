#!/bin/bash
LOG4J_LATEST_VERSION=$(curl -s https://logging.apache.org/log4j/2.x/download.html | grep 'id="projectVersion"' | awk '{ print $3 }' | sed -e 's/<.*>//g')
LOG4J_TAR_URL="https://dlcdn.apache.org/logging/log4j/${LOG4J_LATEST_VERSION}/apache-log4j-${LOG4J_LATEST_VERSION}-bin.tar.gz"
SEARCH_DIR=$1
WORKING_DIR=/tmp/log4j

if [ -z $SEARCH_DIR ]; then
    echo "Usage: ./${0} <dir to search for log4j>"
    exit 1
fi

if [ ! -d $WORKING_DIR ]; then
    mkdir -p $WORKING_DIR
fi

if [ -z $(command -v wget) ]; then
    echo "Error: Wget is not installed. Please install wget."
    exit 1
fi

# attempt to wget newest version
cd $WORKING_DIR/
if wget -q --no-check-certificate $LOG4J_TAR_URL; then
    echo "Retrieved newest LOG4J version ${LOG4J_LATEST_VERSION}."
else
    echo "Error: Unable to retrieve newest Log4j version ${LOG4J_LATEST_VERSION}"
    exit 1
fi

LOG4J_TAR_FILE=apache-log4j-${LOG4J_LATEST_VERSION}-bin.tar.gz
LOG4J_TAR_DIR=$(tar ztvf $LOG4J_TAR_FILE  | head -n 1 | awk '{ print $6 }' | awk -F '/' '{ print $1 }')
WORKING_DIR=${WORKING_DIR}/${LOG4J_TAR_DIR}

# extract log4j
if tar zxf $LOG4J_TAR_FILE; then
    echo "Successfully extracted Log4j tar file"
else
    echo "Error: Unable to extract latest log4j file"
    exit 1
fi

if [ ! -d $LOG4J_TAR_DIR ]; then
    echo "Error: Directory not found: ${LOG4J_TAR_DIR}"
    exit 1
fi


# find log4j files
LOG4J_FILES=$(find $SEARCH_DIR -name "*log4j*.jar" -type f | grep -v ${LOG4J_TAR_DIR})
for file in $LOG4J_FILES
do
    FILENAME=$(basename $file)
    DIRNAME=$(dirname $file)
    CURRENT_VERSION=$(basename $file | grep -Eo '[0-9]+.[0-9+]+.[0-9]')
    LIBRARY_NAME=$(basename $file | sed -e 's/-[0-9]\.[0-9][0-9]\.[0-9].jar//g')

    # copy new file into dir
    NEW_FILENAME="${LIBRARY_NAME}-${LOG4J_LATEST_VERSION}.jar"
    NEW_FILE="${WORKING_DIR}/${NEW_FILENAME}"
    if [ -f "${NEW_FILE}" ]; then
#        echo "Newest version of ${LIBRARY_NAME} is ${LOG4J_LATEST_VERSION} @ ${NEW_FILE}"

        # backup files
        if mv $file $file.bak; then
            echo "Successfully backed up ${file}."
        else
            echo "Error: Unable to backup ${file}."
        fi

        # copy new file to dir
        if cp "${NEW_FILE}" "${DIRNAME}/"; then
            echo "Successfully copied ${NEW_FILENAME} to ${DIRNAME}"
        else
            echo "Error: Unable to copy ${NEW_FILENAME} to ${DIRNAME}"
        fi
    fi
#    ln -s ${LIBRARY_NAME}-${CURRENT_VERSION}.jar ${LIBRARY_NAME}-${LOG4J_LATEST_VERSION}.jar

done