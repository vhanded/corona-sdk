cd src
lua chartboost_build_public.lua || lua.exe chartboost_build_public.lua
luac -o ../dist/chartboost.lua chartboost_library_public.lua
rm chartboost_library_public.lua
cd ..
cp dist/chartboost.lua sample/ChartboostSDK/