unit Chronogears.Azure.Model;

interface

type
  TAzureConnection = class
  public
    TenantId: string;
    SubscriptionId: string;
    ClientId: string;
    ClientSecret: string;
    Resource: string;
    RedirectURL: string;
    AuthorizeEndPoint: string;
    TokenEndPoint: string;
    RESTEndPoint: string;
    AuthCode: string;
    AuthToken: string;
  end;

implementation

end.
