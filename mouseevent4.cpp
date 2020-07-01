#include <windows>

	int inline BlockedKey(WPARAM key)
	{
		return ( (key >= VK_NUMPAD0) && (key <= VK_NUMPAD9));
	}
extern "C" {
	HHOOK __declspec(dllexport) thehook=NULL;
	BOOL  __declspec(dllexport) hook_installed=0;
	LRESULT __stdcall __declspec(dllexport) myKeyboard_hook(int nCode,WPARAM wParam,
					 LPARAM lParam)
	{
			if (nCode < 0)
			{
			 return CallNextHookEx(thehook,nCode,wParam,lParam);
			}
			if (BlockedKey(wParam))
			{
				return 1;	
			}
			else
			{
				return CallNextHookEx(thehook,nCode,wParam,lParam);
			}
	
	}
}