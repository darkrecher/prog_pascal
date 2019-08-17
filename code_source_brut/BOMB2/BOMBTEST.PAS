Uses MCGAGraf,BombImg,KeyBoard;

begin
  MCGAScreen;
  AdvKeyOn;
  LoadImages;
  ClearScreen(2);
  BonusImage.Flamme^.DrawsPlaf(50,50);
  BonusImage.Bombe^.DrawsPlaf(70,50);
  BonusImage.Kick^.DrawsPlaf(90,50);
  AfficheAll;
  While not(K_Esc) and not(K_Enter) do;
  FreeImages;
  AdvKeyOff;
  CloseScreen;
end.