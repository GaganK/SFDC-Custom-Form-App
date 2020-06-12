@isTest
global  class EasyFormsMockHttpResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().contains('TableEnumOrId')){
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Authorization','Bearer 000001');
            String json = '{\"size\":4,\"totalSize\":4,\"done\":true,\"queryLocator\":null,\"entityTypeName\":\"Layout\",\"records\":[{\"attributes\":{\"type\":\"Layout\",\"url\":\"/services/data/v42.0/tooling/sobjects/Layout/00h2w000003Ol0tAAC\"},\"Id\":\"00h2w000003Ol0tAAC\",\"Name\":\"Account (Marketing) Layout\"},{\"attributes\":{\"type\":\"Layout\",\"url\":\"/services/data/v42.0/tooling/sobjects/Layout/00h2w000003Ol0uAAC\"},\"Id\":\"00h2w000003Ol0uAAC\",\"Name\":\"Account (Sales) Layout\"},{\"attributes\":{\"type\":\"Layout\",\"url\":\"/services/data/v42.0/tooling/sobjects/Layout/00h2w000003Ol0vAAC\"},\"Id\":\"00h2w000003Ol0vAAC\",\"Name\":\"Account (Support) Layout\"},{\"attributes\":{\"type\":\"Layout\",\"url\":\"/services/data/v42.0/tooling/sobjects/Layout/00h2w000003Ol0wAAC\"},\"Id\":\"00h2w000003Ol0wAAC\",\"Name\":\"Account Layout\"}]}';
            res.setBody(json);
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('CustomObject')){
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Authorization','Bearer 000001');
            String json = '{\"size\":1,\"totalSize\":1,\"done\":true,\"queryLocator\":null,\"entityTypeName\":\"CustomObject\",\"records\":[{\"attributes\":{\"type\":\"CustomObject\",\"url\":\"/services/data/v42.0/tooling/sobjects/CustomObject/01I2w000000QrmNEAS\"},\"Id\":\"01I2w000000QrmNEAS\",\"DeveloperName\":\"Machine\",\"NamespacePrefix\":null}]}';
            res.setBody(json);
            res.setStatusCode(200);
        }
        return res;
    }
}