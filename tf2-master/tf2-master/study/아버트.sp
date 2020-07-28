new aa[1][4];

public OnPluginStart()
{
	RegConsoleCmd("sm_aa", aaaa);
}
public Action:aaaa(client, args)
{

	aa[0][0] = 0;
	aa[0][1] = 1;
	aa[0][2] = 1;
	aa[0][3] = 1;

	// for(new i = 0; i <= 3; i++) //for문을 무조건 돌려야댐
	// {
		// if(aa[0][i] == 1) //<- 이 부분을 "모두 1이 아니다" 라고 출력을 하면 댐!
		// {
			// PrintToChat(client, "모두 1이 아님");
		// }
		// else PrintToChat(client, "모두 1임");
		
	// }
	new arr=0;
	for(new i=0; i<3; i++)
	{
		if(aa[0][i] == 1)
		{
			arr++
		}
	}
	if(arr == 3)
	{
		PrintToChat(client, "모두 1임");
	}
	else PrintToChat(client, "모두 1이 아님");
			
	return Plugin_Handled;
}

stock bool:bIsNumberSameOn2D(num[][], find, fdarray, sdarray)
{
	new arr=0;
	for(new i=0; i<sdarray; i++)
	{
		if(num[fdarray][i] == find)
		{
			arr++
		}
	}
	if(arr == sdarray)
	{
		return true;
	}
	else return false;
}

stock iIsNumberSameOn2D(num[][], find, fdarray, sdarray)
{
	new arr=0;
	for(new i=0; i<sdarray; i++)
	{
		if(num[fdarray][i] == find)
		{
			arr++
		}
	}
	return arr;
}

stock iIsNumberSameOn2D2(num[][], find, fdarray, sdarray)
{
	new arr=0;
	for(new i=0; i<fdarray; i++)
	{
		new arr2=0;
		for(new j=0; j<sdarray; j++)
		{
			if(num[i][j] == find)
			{
				arr2++
			}
		}
		if(arr2 == sdarray)
		{
			arr++
		}
	}
	return arr;
}
