#!/bin/bash
cat > keycloak.json << EOF
{
        "configEntities": {
            "openIDSettings": {
                "_type": "openIDSettingsType",
                "enabled": true,
                "clientId": "tableau-client",
                "clientSecret": "..................",
                "configURL": "https://keyclaok.net........./auth/realms/tableau-realm/.well-known/openid-configuration",
                "externalURL": "http://ip-address"
                }
          }
}
EOF
