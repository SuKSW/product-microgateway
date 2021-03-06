// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/config;

public type ServerConfigDTO record {
    int timestampSkew = getConfigIntValue(SERVER_CONF_ID, SERVER_TIMESTAMP_SKEW, DEFAULT_SERVER_TIMESTAMP_SKEW);
    string header = getConfigValue(SERVER_CONF_ID, SERVER_HEADER, "");
    serverHeaderDTO[] serverHeaders = getserverHeaders();
};

public type serverHeaderDTO record {
    string headerName;
    boolean preserveHeader;
    string overrideValue;
};

public function getserverHeaders() returns (serverHeaderDTO[]) {
    map<anydata>[] | error serverHeaderMap = map<anydata>[].constructFrom(config:getAsArray(SERVER_HEADER_ID));
    serverHeaderDTO[] serverHeaders = [];
    if (serverHeaderMap is map<anydata>[] && serverHeaderMap.length() > 0) {
        foreach map<anydata> serverHeader in serverHeaderMap {
            anydata headerName = serverHeader[SERVER_HEADER_HEADER_NAME];
            anydata preserveHeader = serverHeader[SERVER_HEADER_PRESERVE_HEADER];
            anydata overrideValue = serverHeader[SERVER_HEADER_OVERRIDE_VALUE];
            if (headerName is string) {
                boolean preserveHeaderVal = DEFAULT_SERVER_HEADERCONF_PRESERVE_HEADER;
                if (headerName.toLowerAscii() == USER_AGENT_HEADER_NAME.toLowerAscii()) {
                    preserveHeaderVal = DEFAULT_SERVER_HEADERCONF_USER_AGENT_PRESERVE_HEADER;
                } else if (headerName.toLowerAscii() == SERVER_HEADER_NAME.toLowerAscii()) {
                    preserveHeaderVal = DEFAULT_SERVER_HEADERCONF_SERVER_PRESERVE_HEADER;
                }
                string overrideValueStr = DEFAULT_SERVER_HEADER;
                if (preserveHeader is boolean) {
                    preserveHeaderVal = preserveHeader;
                } else if (preserveHeader.toString() != "") {
                    error err = error("'preservedHeader' config value is not 'boolean'");
                    panic err;
                }
                if (overrideValue is string) {
                    overrideValueStr = overrideValue;
                } else if (overrideValue.toString() != "") {
                    error err = error("'overrideValue' config value is not 'string'");
                    panic err;
                }
                serverHeaderDTO serverHeaderDto = {headerName: headerName, preserveHeader: preserveHeaderVal,
                                                    overrideValue: overrideValueStr};
                serverHeaders.push(serverHeaderDto);
            } else if (headerName.toString() != "") {
                error err = error("'headerName' config value is not 'string'");
                panic err;
            }
        }
    }
    return serverHeaders;
}
