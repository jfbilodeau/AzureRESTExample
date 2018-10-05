unit Chronogears.Form.Authorize;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.WebBrowser,
  Winapi.Windows,
  Chronogears.Azure.Model;

type
  TAuthorizeForm = class(TForm)
    WebBrowser: TWebBrowser;
    procedure WebBrowserDidFinishLoad(ASender: TObject);
  private
    FConnection: TAzureConnection;
    { Private declarations }
  public
    { Public declarations }
    procedure GetAuthToken(AConnection: TAzureConnection);
  end;

var
  AuthorizeForm: TAuthorizeForm;

implementation

{$R *.fmx}

uses
  System.NetEncoding, System.Net.URLClient;

{ TAuthorizeForm }

procedure TAuthorizeForm.GetAuthToken(AConnection: TAzureConnection);
var
  LURL: string;
begin
  FConnection := AConnection;

  LURL := FConnection.AuthorizeEndPoint +
    '?client_id=' + FConnection.ClientId +
    '&response_type=code' +
    '&redirect_uri=' + TNetEncoding.URL.Encode(FConnection.RedirectURL) +
    '&response_mode=query' +
    '&scope=openid' +
    '&state=1' +
    '&resource=' + TNetEncoding.URL.Encode(FConnection.Resource);

  WebBrowser.URL := LURL;

  ShowModal;
end;

procedure TAuthorizeForm.WebBrowserDidFinishLoad(ASender: TObject);
var
  LURI: TURI;
  LParam: TNameValuePair;
  LError: string;
  LErrorDescription: string;
  LMessage: string;
begin
  if WebBrowser.URL.StartsWith(FConnection.RedirectURL) then
  begin
    LURI := TURI.Create(WebBrowser.URL);

    for LParam in LURI.Params do
    begin
      if LParam.Name = 'code' then
      begin
        WebBrowser.Stop;

        FConnection.AuthCode := LParam.Value;
        ModalResult := mrOk;
        Hide;
        Exit;
      end
      else if LParam.Name = 'error' then
      begin
        LError := LParam.Value;
        LErrorDescription := LURI.ParameterByName['error_description'];
        LMessage := Format('Error: %s (%s)', [LErrorDescription, LError]);

        ShowMessage(LMessage);

        ModalResult := mrCancel;
        Hide;
        Exit;
      end;

    end;
  end;
end;

end.
