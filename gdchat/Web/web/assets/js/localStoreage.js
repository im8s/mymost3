
//本地存储，localStorage类没有存储空间的限制，而cookieStorage有存储大小限制
//在不支持localStorage的情况下会自动切换为cookieStorage
window.dbStorage = (new (function(){
 
    var storage;    //声明一个变量，用于确定使用哪个本地存储函数
 
    if(window.localStorage){
        storage = localStorage;     //当localStorage存在，使用H5方式
    }
    else{
        storage = cookieStorage;    //当localStorage不存在，使用兼容方式
    }
    this.userId="";
    this.getKey=function(key){
        return this.userId+"_"+key;
    };
    this.setItem = function(key, value){
      
       try{
           storage.setItem(this.getKey(key), value);
        }catch(oException){
            if(oException.name == 'QuotaExceededError'){
                console.log('超出本地存储限额！');
                //如果历史信息不重要了，可清空后再设置
                localStorage.clear();
                storage.setItem(this.getKey(key), value);
            }
      }
    };
 
    this.getItem = function(key){
        var value=storage.getItem(this.getKey(key));
       /* if(!(undefined==value||null==value||""==value||"null"==value||NaN==value))
            console.log("dbStorageLog ==> getItem key > "+key);*/
        return value;
    };
 
    this.removeItem = function(key){
         console.log("dbStorageLog ==> removeItem key > "+key);
        storage.removeItem(this.getKey(key));
    };
 
    this.clear = function(){
        console.log("dbStorageLog ==> clearAll =====>");
        storage.clear();
    };

})());