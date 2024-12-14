{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Returns a specified number of random Hex characters.
*/}}
{{- define "jupyterhub.randHex" -}}
  {{- $result := "" -}}
  {{- range $i := until . }}
      {{- $rand_hex_char := mod (randNumeric 4 | atoi) 16 | printf "%x" }}
      {{- $result = print $result $rand_hex_char }}
  {{- end }}
  {{- $result }}
{{- end }}

{{/*
Return the hub image name.
*/}}
{{- define "jupyterhub.hub.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.hub.image "global" .Values.global) }}
{{- end }}

{{/*
Return the hub deployment name.
*/}}
{{- define "jupyterhub.hub.name" -}}
{{- printf "%s-hub" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Return the cookie_secret value for the hub.
*/}}
{{- define "jupyterhub.hub.config.JupyterHub.cookie_secret" -}}
  {{ $hubConfiguration := include "common.tplvalues.render" (dict "value" .Values.hub.configuration "context" $) | fromYaml }}
  {{- if ($hubConfiguration | dig "hub" "config" "JupyterHub" "cookie_secret" "") }}
      {{- $hubConfiguration.hub.config.JupyterHub.cookie_secret }}
  {{- else if ($hubConfiguration | dig "hub" "cookieSecret" "") }}
      {{- $hubConfiguration.hub.cookieSecret }}
  {{- else }}
      {{- $secretData := (lookup "v1" "Secret" $.Release.Namespace (include "jupyterhub.hub.name" .)).data }}
      {{- if hasKey $secretData "hub.config.JupyterHub.cookie_secret" }}
          {{- index $secretData "hub.config.JupyterHub.cookie_secret" | b64dec }}
      {{- else }}
          {{- include "jupyterhub.randHex" 64 }}
      {{- end }}
  {{- end }}
{{- end }}

{{/*
Return the CryptKeeper key value.
*/}}
{{- define "jupyterhub.hub.config.CryptKeeper.keys" -}}
  {{ $hubConfiguration := include "common.tplvalues.render" (dict "value" .Values.hub.configuration "context" $) | fromYaml }}
  {{- if ($hubConfiguration | dig "hub" "config" "CryptKeeper" "keys" "") }}
      {{- $hubConfiguration.hub.config.CryptKeeper.keys | join ";" }}
  {{- else }}
      {{- $secretData := (lookup "v1" "Secret" $.Release.Namespace (include "jupyterhub.hub.name" .)).data }}
      {{- if hasKey $secretData "hub.config.CryptKeeper.keys" }}
          {{- index $secretData "hub.config.CryptKeeper.keys" | b64dec }}
      {{- else }}
          {{- include "jupyterhub.randHex" 64 }}
      {{- end }}
  {{- end }}
{{- end }}

{{/*
Return the API token for a hub service.
*/}}
{{- define "jupyterhub.hub.services.get_api_token" -}}
  {{- $services := .context.Values.hub.services }}
  {{- $explicitly_set_api_token := or (dig .serviceKey "api_token" "" $services) (dig .serviceKey "apiToken" "" $services) }}
  {{- if $explicitly_set_api_token }}
      {{- $explicitly_set_api_token }}
  {{- else }}
      {{- $k8s_state := lookup "v1" "Secret" .context.Release.Namespace (include "jupyterhub.hub.name" .context) | default (dict "data" (dict)) }}
      {{- $k8s_secret_key := printf "hub.services.%s.apiToken" .serviceKey }}
      {{- if hasKey $k8s_state.data $k8s_secret_key }}
          {{- index $k8s_state.data $k8s_secret_key | b64dec }}
      {{- else }}
          {{- include "jupyterhub.randHex" 64 }}
      {{- end }}
  {{- end }}
{{- end }}

{{/*
Validate JupyterHub database configuration.
*/}}
{{- define "jupyterhub.validateValues.database" -}}
{{- if and .Values.postgresql.enabled .Values.externalDatabase.host -}}
    {{ printf "Validation Error: Both internal and external databases are configured. Choose one." }}
{{- else if and (not .Values.postgresql.enabled) (not .Values.externalDatabase.host) -}}
    {{ printf "Validation Error: No database configured. Configure either an internal or external database." }}
{{- end }}
{{- end }}

{{/*
Compile all validation messages.
*/}}
{{- define "jupyterhub.validateValues" -}}
  {{- $messages := list -}}
  {{- $messages := append $messages (include "jupyterhub.validateValues.database" .) -}}
  {{- $messages := without $messages "" -}}
  {{- $message := join "\n" $messages -}}
  {{- if $message -}}
      {{- printf "\nVALUES VALIDATION:\n%s" $message -}}
  {{- end }}
{{- end }}
