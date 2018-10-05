unit Chronogears.Azure.Model;

interface

type
  TAzureConnection = class
  public
    SubscriptionId: string;
    ClientId: string;
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
