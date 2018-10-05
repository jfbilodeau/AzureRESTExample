unit Chronogears.Form.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.ListBox, FMX.Objects,
  FMX.ScrollBox, FMX.Memo, FMX.Edit, IPPeerClient,
  Chronogears.Azure.Model, Chronogears.Form.Authorize, Data.Bind.Components,
  Data.Bind.ObjectScope, REST.Client, REST.Types, REST.Json, System.JSON;

type
  TMainForm = class(TForm)
    CommandLogIn: TButton;
    LabelAuthStatus: TLabel;
    Line1: TLine;
    CommandGetResourceGroups: TButton;
    ListResGroup: TListBox;
    LabelRaw: TLabel;
    LabelList: TLabel;
    Line2: TLine;
    FieldResGroupName: TEdit;
    FieldRawResponse: TMemo;
    CommandCreateResGroup: TButton;
    CommandGetAccessToken: TButton;
    LabelToken: TLabel;
    Line3: TLine;
    RESTTokenRequest: TRESTRequest;
    RESTTokenResponse: TRESTResponse;
    RESTListResGroupRequest: TRESTRequest;
    RESTClient: TRESTClient;
    RESTListResGroupResponse: TRESTResponse;
    RESTCreateResGroupRequest: TRESTRequest;
    RESTCreateResGroupResponse: TRESTResponse;
    procedure FormCreate(Sender: TObject);
    procedure CommandLogInClick(Sender: TObject);
    procedure CommandGetAccessTokenClick(Sender: TObject);
    procedure RESTTokenRequestAfterExecute(Sender: TCustomRESTRequest);
    procedure CommandGetResourceGroupsClick(Sender: TObject);
    procedure RESTListResGroupRequestAfterExecute(Sender: TCustomRESTRequest);
    procedure CommandCreateResGroupClick(Sender: TObject);
    procedure RESTCreateResGroupRequestAfterExecute(Sender: TCustomRESTRequest);
  private
    { Private declarations }
    FConnection: TAzureConnection;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.CommandCreateResGroupClick(Sender: TObject);
var
  LResource: string;
begin
  Cursor := crHourGlass;
  CommandCreateResGroup.Enabled := false;

  LResource := Format(
    'subscriptions/%s/resourcegroups/%s?api-version=2018-02-01',
    [FConnection.SubscriptionId, FieldResGroupName.Text]
  );

  RESTClient.BaseURL := FConnection.RESTEndPoint;

  RESTCreateResGroupRequest.Resource := LResource;
  RESTCreateResGroupRequest.Method := TRESTRequestMethod.rmPUT;

  RESTCreateResGroupRequest.Params.Clear;
  RESTCreateResGroupRequest.Params.AddItem('Authorization', 'Bearer ' + FConnection.AuthToken, TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
//  RESTCreateResGroupRequest.Params.AddItem('Content-Type', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
//  RESTCreateResGroupRequest.Params.AddItem('Accept', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER);

  RESTCreateResGroupRequest.Body.Add('{location:''canadacentral''}', TRESTContentType.ctAPPLICATION_JSON);

  RESTCreateResGroupRequest.Execute;
end;

procedure TMainForm.CommandGetAccessTokenClick(Sender: TObject);
begin
  RestClient.BaseURL := FConnection.TokenEndPoint;

  RESTTokenRequest.Method := TRESTRequestMethod.rmPOST;
  RESTTokenRequest.Params.AddItem('grant_type', 'authorization_code', TRESTRequestParameterKind.pkGetOrPost);
  RESTTokenRequest.Params.AddItem('client_id', FConnection.ClientId, TRESTRequestParameterKind.pkGetOrPost);
  RESTTokenRequest.Params.AddItem('code', FConnection.AuthCode, TRESTRequestParameterKind.pkGetOrPost);
  RESTTokenRequest.Params.AddItem('redirect_uri', FConnection.RedirectURL, TRESTRequestParameterKind.pkGetOrPost);
  RESTTokenRequest.Params.AddItem('resource', FConnection.Resource, TRESTRequestParameterKind.pkGetOrPost, [poDoNotEncode]);

  Cursor := crHourGlass;
  RESTTokenRequest.ExecuteAsync;
end;

procedure TMainForm.CommandGetResourceGroupsClick(Sender: TObject);
begin
  Cursor := crHourGlass;

  RESTClient.BaseURL := FConnection.RESTEndPoint;

  RESTListResGroupRequest.Resource := 'subscriptions/' + FConnection.SubscriptionId + '/resourcegroups?api-version=2018-02-01';

  RESTListResGroupRequest.Params.AddItem('Authorization', 'Bearer ' + FConnection.AuthToken, TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
  RESTListResGroupRequest.Params.AddItem('Content-Type', 'application/json', TRESTRequestParameterKind.pkHTTPHEADER);

  RESTListResGroupRequest.ExecuteAsync;
end;

procedure TMainForm.CommandLogInClick(Sender: TObject);
begin
  AuthorizeForm.GetAuthToken(FConnection);

  if AuthorizeForm.ModalResult = mrOk then
  begin
    LabelAuthStatus.Text := 'Authentication Code: ' + FConnection.AuthCode.Substring(0, 8) + '...';
    CommandGetAccessToken.Enabled := True;
  end;

end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  {$MESSAGE ERROR 'Enter your subscription id and client id below then delete this line'}
  FConnection := TAzureConnection.Create;
  FConnection.SubscriptionId := '<<YOUR SUBSCRIPTION ID>>';
  FConnection.ClientId := '<<YOUR CLIENT ID>>';
  FConnection.Resource := 'https://management.core.windows.net/';
  FConnection.RedirectURL := 'http://chronogears.com/azure';
  FConnection.AuthorizeEndPoint := 'https://login.microsoftonline.com/common/oauth2/authorize';
  FConnection.TokenEndPoint := 'https://login.microsoftonline.com/common/oauth2/token';
  FConnection.RESTEndPoint := 'https://management.azure.com';
end;

procedure TMainForm.RESTCreateResGroupRequestAfterExecute(
  Sender: TCustomRESTRequest);
begin
  Cursor := crArrow;
  CommandCreateResGroup.Enabled := true;

  CommandGetResourceGroupsClick(Sender);
end;

procedure TMainForm.RESTListResGroupRequestAfterExecute(Sender: TCustomRESTRequest);
var
  ResGroup: TJSONValue;
  ResGroupName: string;
begin
  Cursor := crArrow;

  FieldRawResponse.Text := TJSON.Format(RESTListResGroupResponse.JSONValue);

  ListResGroup.Items.Clear;

  for ResGroup in RESTListResGroupResponse.JSONValue.GetValue<TJSONArray>('value') do
  begin
    ResGroupName := ResGroup.GetValue<string>('name');
    ListResGroup.Items.Add(ResGroupName);
  end;
end;

procedure TMainForm.RESTTokenRequestAfterExecute(Sender: TCustomRESTRequest);
begin
  Cursor := crArrow;

  FConnection.AuthToken := RESTTokenResponse.JSONValue.GetValue<String>('access_token');

  LabelToken.Text := 'Access Token: ' + FConnection.AuthToken.Substring(0, 8) + '...';

  CommandGetResourceGroups.Enabled := True;
  CommandCreateResGroup.Enabled := True;
end;

end.
