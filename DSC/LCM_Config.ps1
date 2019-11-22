[DSCLocalConfigurationManager()]
Configuration LCMConfig
{
	Node localhost
	{
		Settings
		{
			ConfigurationMode = 'ApplyAndAutoCorrect'
		}
	}
}

LCMConfig
Set-DscLocalConfigurationManager -Path .\LCMConfig -Verbose