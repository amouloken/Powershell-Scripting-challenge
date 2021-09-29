function Test-NetIPAddress
{
	<#
	.SYNOPSIS
	Tests if a given IPv4 address a.b.c.d exists within the range of addresses given by e.f.g.h/x.
	.DESCRIPTION
	Tests if a given IPv4 address a.b.c.d exists within the range of addresses given by e.f.g.h/x.
	Returns a boolean true if the IP address is in the network range, or a boolean false otherwise.
	Setting the Detailed switch will instead return a custom object with additional network information.
	.PARAMETER IPAddress
	The IP address to test. Should be given in 0.0.0.0 format.
	.PARAMETER NetworkAddress
	The address of the network that the IP address will be tested against. Should be given in 0.0.0.0 format.
	Optionally, the subnet mask may be specified here by appending the routing prefix e.g. 192.168.0.0/16.
	If the subnet mask is provided here, then the NetworkAddressMask parameter should not be used.
	.PARAMETER NetworkAddressMask
	The subnet mask for the NetworkAddress.
	May be given as either a routing prefix (i.e. an integer from 1 to 32) or in IP format e.g. 255.255.255.0.
	If the subnet mask is provided here, then it should not be provided as a routing prefix in the NetworkAddress parameter.
	.PARAMETER Detailed
	Changes the output to a custom object with additional network information.
	.EXAMPLE
	PS C:\> Test-NetIPAddress -IPAddress '172.16.2.33' -NetworkAddress '172.16.0.0\17'
	True
	# The following are equivalent to the example above:
	PS C:\> Test-NetIPAddress -IPAddress '172.16.2.33' -NetworkAddress '172.16.0.0' -NetworkAddressMask 17
	PS C:\> Test-NetIPAddress -IPAddress '172.16.2.33' -NetworkAddress '172.16.0.0' -NetworkAddressMask '255.255.128.0'
	.EXAMPLE
	PS C:\> Test-NetIPAddress -IPAddress '172.16.2.33' -NetworkAddress '172.16.0.0\17' -Detailed
	IPAddress          : 172.16.2.33
	NetworkAddressCIDR : 172.16.0.0/17
	NetworkAddress     : 172.16.0.0
	RoutingPrefix      : 17
	NetworkMask        : 255.255.128.0
	BroadcastAddress   : 172.16.127.255
	AddressCount       : 32768
	InNetwork          : True
	.EXAMPLE
	PS C:\> 30..40 | ForEach-Object { '172.16.2.'+$_ } | Test-NetIPAddress -NetworkAddress '172.16.2.32' -NetworkAddressMask 30 -Detailed | Format-Table
	IPAddress   NetworkAddressCIDR NetworkAddress RoutingPrefix NetworkMask     BroadcastAddress AddressCount InNetwork
	---------   ------------------ -------------- ------------- -----------     ---------------- ------------ ---------
	172.16.2.30 172.16.2.32/30     172.16.2.32    30            255.255.255.252 172.16.2.35                 4     False
	172.16.2.31 172.16.2.32/30     172.16.2.32    30            255.255.255.252 172.16.2.35                 4     False
	172.16.2.32 172.16.2.32/30     172.16.2.32    30            255.255.255.252 172.16.2.35                 4      True
	172.16.2.33 172.16.2.32/30     172.16.2.32    30            255.255.255.252 172.16.2.35                 4      True
	172.16.2.34 172.16.2.32/30     172.16.2.32    30            255.255.255.252 172.16.2.35                 4      True
	172.16.2.35 172.16.2.32/30     172.16.2.32    30            255.255.255.252 172.16.2.35                 4      True
	172.16.2.36 172.16.2.32/30     172.16.2.32    30            255.255.255.252 172.16.2.35                 4     False
	172.16.2.37 172.16.2.32/30     172.16.2.32    30            255.255.255.252 172.16.2.35                 4     False
	172.16.2.38 172.16.2.32/30     172.16.2.32    30            255.255.255.252 172.16.2.35                 4     False
	172.16.2.39 172.16.2.32/30     172.16.2.32    30            255.255.255.252 172.16.2.35                 4     False
	172.16.2.40 172.16.2.32/30     172.16.2.32    30            255.255.255.252 172.16.2.35                 4     False
	.NOTES
	Author : nmbell
	#>

    # Use cmdlet binding
    [CmdletBinding()]

    # Declare parameters
	Param
	(

		[Parameter(
		  Mandatory                       = $true
		, ValueFromPipeline               = $true
		, ValueFromPipelineByPropertyName = $true
		)]
		[Alias('IPV4Address')]
		[IPAddress]
		$IPAddress

	,	[Parameter(
		  Mandatory                       = $true
		, ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		)]
		[String]
		$NetworkAddress

	,	[Parameter(
		  ValueFromPipeline               = $false
		, ValueFromPipelineByPropertyName = $true
		)]
		[Alias('Mask')]
		[String]
		$NetworkAddressMask

	,	[Switch]
		$Detailed

    )

	BEGIN
	{
	}

	PROCESS
	{
		Write-Verbose "Testing IP address: $($IPAddress.ToString())"

		# Parse the network address
		$NetworkAddress = $NetworkAddress.Replace('\','/')
		$networkIP      = [IPAddress]$NetworkAddress.Split('/')[0]
		$maskString     = $NetworkAddress.Split('/')[1]

		# Require the mask to be specified exactly once
		If (($maskString -and $NetworkAddressMask) -or (!($maskString -or $NetworkAddressMask)))
		{
			Write-Error 'Network mask must be provided exactly once, as either a suffix to the NetworkAddress parameter or with the NetworkAddressMask parameter.' -ErrorAction Stop
		}

		# Get the network mask values
		If ($NetworkAddressMask) { $maskString = $NetworkAddressMask }
		If ($maskString -match '^\d{1,2}$' -and $maskString -ge 1 -and $maskString -le 32) # assume an integer between 1 and 32 is a routing prefix
		{
			$networkMask = Get-NetIPMask -RoutingPrefix $maskString
		}
		Else
		{
			$networkMask = Get-NetIPMask -Mask $maskString
		}
		Write-Verbose "Against network: $($networkIP.ToString())/$($networkMask.RoutingPrefix)"

		# Calculate the first address in the network range
		$networkFirst = [IPAddress]($networkIP.Address -band $networkMask.Address)
		Write-Verbose "First address in network: $($networkFirst.ToString())"

		# Calculate the last address in the range
		$wildcardMask = [IPAddress]($networkMask.Address -bxor [UInt32]::MaxValue)
		$networkLast  = [IPAddress]($networkIP.Address -bor $wildcardMask.Address)
		Write-Verbose "Last address in network: $($networkLast.ToString())"

		# Compare the IP address with network address range
		$ipInNetwork = $IPAddress.Address -ge $networkFirst.Address -and $IPAddress.Address -le $networkLast.Address
		Write-Verbose "IP address $($IPAddress.ToString()) is $('not '*(!$ipInNetwork))in network $($networkIP.ToString())/$($networkMask.RoutingPrefix)"

		# Output
		If ($Detailed)
		{
			[PSCustomObject]@{
				IPAddress          = $IPAddress
				NetworkAddressCIDR = $networkFirst.ToString()+'/'+$networkMask.RoutingPrefix.ToString()
				NetworkAddress     = $networkFirst.ToString()
				RoutingPrefix      = $networkMask.RoutingPrefix.ToString()
				NetworkMask        = $networkMask.ToString()
				BroadcastAddress   = $networkLast.ToString()
				AddressCount       = [Math]::Pow(2,(32-$networkMask.RoutingPrefix))
				InNetwork          = $ipInNetwork
			}
		}
		Else
		{
			Write-Output $ipInNetwork
		}
    }

	END
	{
	}
}
