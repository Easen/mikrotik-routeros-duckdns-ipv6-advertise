:local duckdnsSubDomain "example-sub-domain"
:local duckdnsToken "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
:local ipv6Interface "bridge1"

# ~~~~~~~~~~ Dont change this code ~~~~~~~~~~~~~

:local previousIP; :local currentIP
# DuckDNS Full Domain (FQDN)
:local duckdnsFullDomain "$duckdnsSubDomain.duckdns.org"

:log debug message="START: DuckDNS.org DDNS Update ($duckdnsFullDomain)"

# Resolve current DuckDNS subdomain ip address
:do {:set previousIP [:resolve $duckdnsFullDomain]} on-error={ :log warning "DuckDNS: Could not resolve dns name $duckdnsFullDomain" };

# Get our public IP adsress from the advertise
:do {
	:local ipv6Subnet [/ipv6/address/get [find advertise=yes interface=$ipv6Interface ] address];
	:set currentIP [:pick $ipv6Subnet 0 [:find $ipv6Subnet "/"]];
} on-error={ :log warning "DuckDNS: Could not find an IPv6 address on $ipv6Interface" };

:log debug "DuckDNS ($duckdnsFullDomain): DNS IP ($previousIP), current internet IP ($currentIP)"

:if ($currentIP != $previousIP) do={
	:log info "DuckDNS ($duckdnsFullDomain): Current IP $currentIP is not equal to previous IP, update needed"
	:log info "DuckDNS ($duckdnsFullDomain): Sending update for $duckdnsFullDomain"
	:local duckRequestUrl "https://www.duckdns.org/update\?domains=$duckdnsSubDomain&token=$duckdnsToken&ipv6=$currentIP&verbose=true"
	:log debug "DuckDNS ($duckdnsFullDomain): using GET request: $duckRequestUrl"

	:local duckResponse
	:do {:set duckResponse ([/tool fetch url=$duckRequestUrl output=user as-value]->"data")} on-error={
		:log error "DuckDNS: could not send GET request to the DuckDNS server. Going to try again in a while."
		:delay 5m;
			:do {:set duckResponse ([/tool fetch url=$duckRequestUrl output=user as-value]->"data")} on-error={
				:log error "DuckDNS: could not send GET request to the DuckDNS server for the second time."
				:error "DuckDNS: bye!"
			}
	}

	# Checking server's answer
	:if ([:pick $duckResponse 0 2] = "OK") do={
		:log info "DuckDNS ($duckdnsFullDomain): New IP address ($currentIP) for domain $duckdnsFullDomain has been successfully set!"
	} else={ 
		:log warning "DuckDNS ($duckdnsFullDomain): There is an error occurred during IP address update, server did not answer with \"OK\" response!"
	}

	:log info "DuckDNS ($duckdnsFullDomain): server answer is: $duckResponse"
} else={
	:log info "DuckDNS ($duckdnsFullDomain): Previous IP ($previousIP) is equal to current IP ($currentIP), no need to update"
}

:log debug message="END: DuckDNS.org DDNS Update finished ($duckdnsFullDomain)"
