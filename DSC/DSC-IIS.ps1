Configuration WWWHostConfig
{
	Node localhost
	{
		WindowsFeature "IIS_Server"
		{
			Name = "Web-Server"
			Ensure = "Present"
		}
		Service "IIS_Service_running"
		{
			Name = "W3SVC"
			State = "Running"
			DependsOn = "[WindowsFeature]IIS_Server"
		}
	}
}

WWWHostConfig
Start-DSCConfiguration -Path .\WWWHostConfig -Verbose -Force -Wait  