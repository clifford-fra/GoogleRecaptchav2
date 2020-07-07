({
    /**
    * Call Apex Server-Side method in Promise
    */
    sendRequest : function(cmp, methodName, params){
        return new Promise($A.getCallback(function(resolve, reject) {
        var action = cmp.get(methodName);
        action.setParams(params);
        action.setCallback(self, function(res) {
            var state = res.getState();
            if(state === 'SUCCESS') {
            resolve(res.getReturnValue());
            } else if(state === 'ERROR') {
            reject(action.getError())
            }
        });
        $A.enqueueAction(action);
        }));
    }
})