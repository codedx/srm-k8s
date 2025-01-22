{{/*
Job content for creating or updating the internal service API key.
*/}}
{{- define "srm-web.key-job" -}}
echo 'Waiting for SRM Web connectivity...'
sleep 45 # delay for potential termination of existing web workload (terminationGracePeriodSeconds=30)
while [ 1 ]; do if (timeout 2 bash -c "</dev/tcp/{{ include "srm-web.fullname" . }}/{{ .Values.web.service.port }}" echo $?); then echo 'Connected to SRM Web'; break; else echo 'SRM Web has not yet responded; retrying...'; sleep 2; fi; done

{{- if .Values.web.caConfigMap }}
export CURL_CA_BUNDLE=/certs/ca.crt
{{- end }}

echo 'Waiting for SRM Web Ready status...'
while [ 1 ]; do READYRESPONSE=$(curl -f {{ include "srm-web.serviceurl" . }}/x/system-status); echo $READYRESPONSE | grep '"state":"ready"'; if [ $? -eq 0 ]; then echo 'SRM Web is ready'; break; else echo "SRM Web is not yet ready: $READYRESPONSE"; echo 'retrying...'; sleep 2; fi; done

ADMINPWD=$(cat '{{ include "srm-web.admin.password.path" . }}')
ADMINCRED=$(echo -n "admin:$ADMINPWD" | base64 --wrap=0)

echo 'Waiting for SRM Web API...'
while [ 1 ]; do curl -f {{ include "srm-web.serviceurl" . }}/x/system-info; if [ $? -eq 0 ]; then echo; echo 'SRM Web API is available'; break; else echo 'SRM Web API is not yet available - is your SRM Web license installed?'; echo 'retrying...'; sleep 2; fi; done

NAME='scan-service-srm-api-key'
ID_PATTERN="\"id\":([0-9]*),\"name\":\"$NAME\""
KEYRESPONSE=$(curl -f -H "Authorization: Basic $ADMINCRED" {{ include "srm-web.serviceurl" . }}/x/admin/users/key?includeInternal=1)
if [ 0 -ne $? ]; then echo 'Failed to make request to "{{ include "srm-web.serviceurl" . }}/x/admin/users/key?includeInternal=1" - does your admin K8s secret "{{ include "srm-web.web.secret" . }}" have the correct password?'; exit 1; fi

KEY_DURATION="{{ .Values.web.scanfarm.key.validForDays }}d"
echo "Key duration is $KEY_DURATION, with regen schedule '{{ .Values.web.scanfarm.key.regenSchedule }}'"

if [[ $KEYRESPONSE =~ $ID_PATTERN ]]
then
  echo "Regenerating key for user ID ${BASH_REMATCH[1]}..."
  RESPONSE=$(curl \
    -f \
    -H "Authorization: Basic $ADMINCRED" \
    -H "Content-Type: application/json" \
    -d "{\"expirationDuration\":\"$KEY_DURATION\"}" \
    {{ include "srm-web.serviceurl" . }}/x/admin/users/key/${BASH_REMATCH[1]}/regenerate)
  if [ 0 -ne $? ]; then echo 'Failed to regenerate service key'; exit 1; fi
else
  echo "Generating key for user $NAME..."
  RESPONSE=$(curl \
    -f \
    -H "Authorization: Basic $ADMINCRED" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$NAME\",\"expirationDuration\":\"$KEY_DURATION\"}" \
    {{ include "srm-web.serviceurl" . }}/x/admin/users/key/internal-service)
  if [ 0 -ne $? ]; then echo 'Failed to generate new service key'; exit 1; fi
fi

KEY=$(echo $RESPONSE | grep -oP '(?<=secret":")[^"]*')
KEYDOC=$(echo -n "{\"secret\":\"$KEY\"}" | base64 --wrap=0)

DATA="{\"apiVersion\":\"v1\",\"kind\":\"Secret\",\"metadata\":{\"namespace\":\"{{ .Release.Namespace }}\",\"name\":\"$NAME\"},\"type\":\"Opaque\",\"data\":{\"srm-api.key\":\"$KEYDOC\"}}"

curl -k -f -s -S -o /dev/null -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" -H "Accept: application/json" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT_HTTPS/api/v1/namespaces/{{ .Release.Namespace }}/secrets/$NAME
if [ 0 -eq $? ]
then
  echo "Updating existing K8s secret resource named $NAME..."
  curl -k -f -s -S -o /dev/null \
    -XPATCH \
    -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    -H "Accept: application/json" \
    -H "Content-Type: application/strategic-merge-patch+json" \
    -d $DATA \
    https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT_HTTPS/api/v1/namespaces/{{ .Release.Namespace }}/secrets/$NAME
  if [ 0 -ne $? ]; then echo 'Failed to update the existing K8s secret for the SRM API key'; exit 1; fi
else
  echo "Creating new K8s secret resource named $NAME..."
  curl -k -f -s -S -o /dev/null \
    -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    -H "Content-Type: application/json" \
    -d $DATA \
    https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT_HTTPS/api/v1/namespaces/{{ .Release.Namespace }}/secrets
  if [ 0 -ne $? ]; then echo 'Failed to create a new K8s secret containing the SRM API key'; exit 1; fi
fi
exit $?
{{- end -}}