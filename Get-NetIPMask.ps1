function Get-NetIPMask
{
	<#
	.SYNOPSIS
	Determines the network mask from either its routing prefix or IP address.
	.DESCRIPTION
	Determines the network mask from either its routing prefix or IP address.
	.PARAMETER RoutingPrefix
	The integer value of the routing prefix.
	.PARAMETER Mask
	The IP value of the mask.
	.EXAMPLE
	PS C:\> Get-NetIPMask -RoutingPrefix 17
	RoutingPrefix      : 17
	Address            : 8454143
	AddressFamily      : InterNetwork
	ScopeId            :
	IsIPv6Multicast    : False
	IsIPv6LinkLocal    : False
	IsIPv6SiteLocal    : False
	IsIPv6Teredo       : False
	IsIPv4MappedToIPv6 : False
	IPAddressToString  : 255.255.128.0
	.EXAMPLE
	PS C:\> Get-NetIPMask -Mask '255.255.0.0'
	RoutingPrefix      : 16
	Address            : 65535
	AddressFamily      : InterNetwork
	ScopeId            :
	IsIPv6Multicast    : False
	IsIPv6LinkLocal    : False
	IsIPv6SiteLocal    : False
	IsIPv6Teredo       : False
	IsIPv4MappedToIPv6 : False
	IPAddressToString  : 255.255.0.0
	.NOTES
	Author : nmbell
	#>

    # Use cmdlet binding
    [CmdletBinding()]

    # Declare parameters
	Param
	(

		[Parameter(
			ParameterSetName = 'RoutingPrefix'
		,	Mandatory = $true
		)]
		[ValidateRange(1,32)]
		[Int]
		$RoutingPrefix

	,	[Parameter(
			ParameterSetName = 'Mask'
		,	Mandatory = $true
		)]
		[IPAddress]
		$Mask

    )

	BEGIN
	{
	}

	PROCESS
	{
		If ($RoutingPrefix)
		{
			$maskBinary = ('1'*$RoutingPrefix).PadRight(32,'0') # string representation
			$maskOctets = $maskBinary -split '(\d{8})' | Where-Object { $_ } | ForEach-Object { [System.Convert]::ToByte($_,2) }
			$maskIP     = [IPAddress]($maskOctets -join '.')
			$maskRP     = $RoutingPrefix
		}

		If ($Mask)
		{
			$maskBinary = ($Mask.GetAddressBytes() | ForEach-Object { [System.Convert]::ToString($_,2).PadLeft(8,'0') }) -join '' # string representation
			$maskRP     = $maskBinary.IndexOf('0')
			$maskIP     = $Mask
		}

		$maskIP | Add-Member -MemberType NoteProperty -Name RoutingPrefix -Value $maskRP -PassThru
    }

	END
	{
	}
}
