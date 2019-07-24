program Chapter3_SDL2;

{ https://www.freepascal-meets-sdl.net/chapter-3-first-steps/ }

uses Crt,SDL2;

begin

  Write('youpi');

  //initilization of video subsystem

  if SDL_Init( SDL_INIT_VIDEO ) < 0 then begin
    Write('fail.');
    HALT;
  end;

  Write('success.');



  //your SDL2 application/game
  SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, 'Pouet', 'Re Pouet', nil);


  //shutting down video subsystem
  SDL_Quit;


end.
