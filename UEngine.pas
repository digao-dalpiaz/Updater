unit UEngine;

interface

uses System.Classes;

type
 TEngine = class(TThread)
  protected
    procedure Execute; override;
 end;

implementation

procedure TEngine.Execute;
begin
  inherited;

end;

end.
