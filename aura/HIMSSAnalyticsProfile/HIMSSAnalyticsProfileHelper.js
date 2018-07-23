({
    /* 
     * Perform a simple self-test to see if the VM is working 
     */ 
    md5_vm_test : function(helper) {
        return helper.hex_md5("abc",helper) == "900150983cd24fb0d6963f7d28e17f72"; 
    },
    gotoHIMSS : function(component, helper) {
        var CurrDate; 
        var Hash; 
        var Link; 
        var tmp; 
        var UniqueId; 
        var sUser; 
        var sPass; 
        var sURL;
        
        // Assign Variables 
        sURL = "https://www.himssanalytics.org/hadatabase/vendor/CRMUser/index.asp"; 
        UniqueId = component.get("v.UniqueId");
        sUser = "CRMLink_Availity"; 
        sPass = "cb7wMGMdjlBrweYk"; 
        CurrDate = helper.GMTime(helper); 
        tmp = helper.hex_md5(CurrDate + sPass, helper); 
        Hash = tmp.substr(0,16); 
        
        // URL Link to HA Database 
        Link = sURL + "?User=" + sUser + "&UniqueId=" + UniqueId + "&tTimeStamp=" + escape(CurrDate) + "&Token=" + Hash; 
        console.log("HIMSSAnalyticsProfile Link: "+Link);
        
        /* Function to determine if HIMSS Facility Unique ID is empty 
           If empty, a message appears 
        */ 
        if(UniqueId === undefined || UniqueId === '' || UniqueId === null) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "info",
                "title": "Informational Message",
                "message": "This account doesn't have a HIMSS Unique ID"
            });
            toastEvent.fire();
        } else {
            console.log("HIMSSAnalyticsProfile opening Link!");
//            window.location.replace(Link);
//            window.open(Link,'_blank'); 
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": Link
            });
            urlEvent.fire();
        } 
    },
    /* 
     * These are the functions you'll usually want to call 
     * They take string arguments and return either hex or base-64 encoded strings 
     */ 
    hex_md5 : function(s,helper) {
        var tmp = helper.str2binl(s,helper);
        var tmp2 = helper.core_md5(tmp, s.length * 8,helper);
        return helper.binl2hex(tmp2,helper);
    },
    b64_md5 : function(s,helper) { 
        var tmp = helper.str2binl(s,helper);
        var tmp2 = helper.core_md5(tmp, s.length * 8,helper);
        return helper.binl2b64(tmp2,helper);
    },
    str_md5 : function(s,helper) { 
        var tmp = helper.str2binl(s,helper);
        var tmp2 = helper.core_md5(tmp, s.length * 8,helper);
        return helper.binl2str(tmp2,helper);
    }, 
    hex_hmac_md5 : function(key, data, helper) {
        var tmp = helper.core_hmac_md5(key, data, helper);
        return helper.binl2hex(tmp,helper);
    },
    b64_hmac_md5 : function(key, data, helper) { 
        var tmp = helper.core_hmac_md5(key, data, helper);
        return helper.binl2b64(tmp,helper);
    },
    str_hmac_md5 : function(key, data, helper) {
        var tmp = helper.core_hmac_md5(key, data, helper);
        return helper.binl2str(tmp,helper);
    },
    /* 
     * Calculate the MD5 of an array of little-endian words, and a bit length 
     */ 
    core_md5 : function(x, len, helper) { 
        /* append padding */ 
        x[len >> 5] |= 0x80 << ((len) % 32); 
        x[(((len + 64) >>> 9) << 4) + 14] = len; 
        
        var a = 1732584193; 
        var b = -271733879; 
        var c = -1732584194; 
        var d = 271733878; 
        
        for(var i = 0; i < x.length; i += 16) { 
            var olda = a; 
            var oldb = b; 
            var oldc = c; 
            var oldd = d; 
            
            a = helper.md5_ff(a, b, c, d, x[i+ 0], 7 , -680876936, helper); 
            d = helper.md5_ff(d, a, b, c, x[i+ 1], 12, -389564586, helper); 
            c = helper.md5_ff(c, d, a, b, x[i+ 2], 17, 606105819, helper); 
            b = helper.md5_ff(b, c, d, a, x[i+ 3], 22, -1044525330, helper); 
            a = helper.md5_ff(a, b, c, d, x[i+ 4], 7 , -176418897, helper); 
            d = helper.md5_ff(d, a, b, c, x[i+ 5], 12, 1200080426, helper); 
            c = helper.md5_ff(c, d, a, b, x[i+ 6], 17, -1473231341, helper); 
            b = helper.md5_ff(b, c, d, a, x[i+ 7], 22, -45705983, helper); 
            a = helper.md5_ff(a, b, c, d, x[i+ 8], 7 , 1770035416, helper); 
            d = helper.md5_ff(d, a, b, c, x[i+ 9], 12, -1958414417, helper); 
            c = helper.md5_ff(c, d, a, b, x[i+10], 17, -42063, helper); 
            b = helper.md5_ff(b, c, d, a, x[i+11], 22, -1990404162, helper); 
            a = helper.md5_ff(a, b, c, d, x[i+12], 7 , 1804603682, helper); 
            d = helper.md5_ff(d, a, b, c, x[i+13], 12, -40341101, helper); 
            c = helper.md5_ff(c, d, a, b, x[i+14], 17, -1502002290, helper); 
            b = helper.md5_ff(b, c, d, a, x[i+15], 22, 1236535329, helper); 
            
            a = helper.md5_gg(a, b, c, d, x[i+ 1], 5 , -165796510, helper); 
            d = helper.md5_gg(d, a, b, c, x[i+ 6], 9 , -1069501632, helper); 
            c = helper.md5_gg(c, d, a, b, x[i+11], 14, 643717713, helper); 
            b = helper.md5_gg(b, c, d, a, x[i+ 0], 20, -373897302, helper); 
            a = helper.md5_gg(a, b, c, d, x[i+ 5], 5 , -701558691, helper); 
            d = helper.md5_gg(d, a, b, c, x[i+10], 9 , 38016083, helper); 
            c = helper.md5_gg(c, d, a, b, x[i+15], 14, -660478335, helper); 
            b = helper.md5_gg(b, c, d, a, x[i+ 4], 20, -405537848, helper); 
            a = helper.md5_gg(a, b, c, d, x[i+ 9], 5 , 568446438, helper); 
            d = helper.md5_gg(d, a, b, c, x[i+14], 9 , -1019803690, helper); 
            c = helper.md5_gg(c, d, a, b, x[i+ 3], 14, -187363961, helper); 
            b = helper.md5_gg(b, c, d, a, x[i+ 8], 20, 1163531501, helper); 
            a = helper.md5_gg(a, b, c, d, x[i+13], 5 , -1444681467, helper); 
            d = helper.md5_gg(d, a, b, c, x[i+ 2], 9 , -51403784, helper); 
            c = helper.md5_gg(c, d, a, b, x[i+ 7], 14, 1735328473, helper); 
            b = helper.md5_gg(b, c, d, a, x[i+12], 20, -1926607734, helper); 
            
            a = helper.md5_hh(a, b, c, d, x[i+ 5], 4 , -378558, helper); 
            d = helper.md5_hh(d, a, b, c, x[i+ 8], 11, -2022574463, helper); 
            c = helper.md5_hh(c, d, a, b, x[i+11], 16, 1839030562, helper); 
            b = helper.md5_hh(b, c, d, a, x[i+14], 23, -35309556, helper); 
            a = helper.md5_hh(a, b, c, d, x[i+ 1], 4 , -1530992060, helper); 
            d = helper.md5_hh(d, a, b, c, x[i+ 4], 11, 1272893353, helper); 
            c = helper.md5_hh(c, d, a, b, x[i+ 7], 16, -155497632, helper); 
            b = helper.md5_hh(b, c, d, a, x[i+10], 23, -1094730640, helper); 
            a = helper.md5_hh(a, b, c, d, x[i+13], 4 , 681279174, helper); 
            d = helper.md5_hh(d, a, b, c, x[i+ 0], 11, -358537222, helper); 
            c = helper.md5_hh(c, d, a, b, x[i+ 3], 16, -722521979, helper); 
            b = helper.md5_hh(b, c, d, a, x[i+ 6], 23, 76029189, helper); 
            a = helper.md5_hh(a, b, c, d, x[i+ 9], 4 , -640364487, helper); 
            d = helper.md5_hh(d, a, b, c, x[i+12], 11, -421815835, helper); 
            c = helper.md5_hh(c, d, a, b, x[i+15], 16, 530742520, helper); 
            b = helper.md5_hh(b, c, d, a, x[i+ 2], 23, -995338651, helper); 
            
            a = helper.md5_ii(a, b, c, d, x[i+ 0], 6 , -198630844, helper); 
            d = helper.md5_ii(d, a, b, c, x[i+ 7], 10, 1126891415, helper); 
            c = helper.md5_ii(c, d, a, b, x[i+14], 15, -1416354905, helper); 
            b = helper.md5_ii(b, c, d, a, x[i+ 5], 21, -57434055, helper); 
            a = helper.md5_ii(a, b, c, d, x[i+12], 6 , 1700485571, helper); 
            d = helper.md5_ii(d, a, b, c, x[i+ 3], 10, -1894986606, helper); 
            c = helper.md5_ii(c, d, a, b, x[i+10], 15, -1051523, helper); 
            b = helper.md5_ii(b, c, d, a, x[i+ 1], 21, -2054922799, helper); 
            a = helper.md5_ii(a, b, c, d, x[i+ 8], 6 , 1873313359, helper); 
            d = helper.md5_ii(d, a, b, c, x[i+15], 10, -30611744, helper); 
            c = helper.md5_ii(c, d, a, b, x[i+ 6], 15, -1560198380, helper); 
            b = helper.md5_ii(b, c, d, a, x[i+13], 21, 1309151649, helper); 
            a = helper.md5_ii(a, b, c, d, x[i+ 4], 6 , -145523070, helper); 
            d = helper.md5_ii(d, a, b, c, x[i+11], 10, -1120210379, helper); 
            c = helper.md5_ii(c, d, a, b, x[i+ 2], 15, 718787259, helper); 
            b = helper.md5_ii(b, c, d, a, x[i+ 9], 21, -343485551, helper); 
            
            a = helper.safe_add(a, olda, helper); 
            b = helper.safe_add(b, oldb, helper); 
            c = helper.safe_add(c, oldc, helper); 
            d = helper.safe_add(d, oldd, helper); 
        } 
        return Array(a, b, c, d); 
    },
    /* 
     * These functions implement the four basic operations the algorithm uses. 
     */
    md5_cmn : function(q, a, b, x, s, t, helper) { 
        return helper.safe_add(helper.bit_rol(helper.safe_add(helper.safe_add(a, q, helper), helper.safe_add(x, t, helper), helper), s, helper),b, helper);
    },
    md5_ff : function(a, b, c, d, x, s, t, helper) {
        return helper.md5_cmn((b & c) | ((~b) & d), a, b, x, s, t, helper); 
    },
    md5_gg : function(a, b, c, d, x, s, t, helper) { 
        return helper.md5_cmn((b & d) | (c & (~d)), a, b, x, s, t, helper); 
    },
    md5_hh : function(a, b, c, d, x, s, t, helper) { 
        return helper.md5_cmn(b ^ c ^ d, a, b, x, s, t, helper); 
    },
    md5_ii : function(a, b, c, d, x, s, t, helper) { 
        return helper.md5_cmn(c ^ (b | (~d)), a, b, x, s, t, helper); 
    },
    /* 
     * Calculate the HMAC-MD5, of a key and some data 
     */ 
    core_hmac_md5 : function(key, data, helper) { 
        var bkey = helper.str2binl(key, helper);
        if(bkey.length > 16) bkey = helper.core_md5(bkey, key.length * 8, helper); 
        
        var ipad = Array(16), opad = Array(16); 
        for(var i = 0; i < 16; i++) 
        { 
            ipad[i] = bkey[i] ^ 0x36363636; 
            opad[i] = bkey[i] ^ 0x5C5C5C5C; 
        } 
        
        var hash = helper.core_md5(ipad.concat(helper.str2binl(data, helper)), 512 + data.length * 8, helper); 
        return helper.core_md5(opad.concat(hash), 512 + 128, helper); 
    },
    /* 
     * Add integers, wrapping at 2^32. This uses 16-bit operations internally 
     * to work around bugs in some JS interpreters. 
     */ 
    safe_add : function(x, y, helper) { 
        var lsw = (x & 0xFFFF) + (y & 0xFFFF); 
        var msw = (x >> 16) + (y >> 16) + (lsw >> 16); 
        return (msw << 16) | (lsw & 0xFFFF); 
    },
    
    /* 
     * Bitwise rotate a 32-bit number to the left. 
     */ 
    bit_rol : function(num, cnt, helper) { 
        return (num << cnt) | (num >>> (32 - cnt)); 
    },
    
    /* 
     * Convert a string to an array of little-endian words 
     * If chrsz is ASCII, characters >255 have their hi-byte silently ignored. 
     */ 
    str2binl : function(str, helper) { 
        var bin = Array(); 
        var mask = (1 << 8) - 1; 
        for(var i = 0; i < str.length * 8; i += 8) 
            bin[i>>5] |= (str.charCodeAt(i / 8) & mask) << (i%32); 
        return bin; 
    },
    /* 
     * Convert an array of little-endian words to a string 
     */ 
    binl2str : function(bin, helper) { 
        var str = ""; 
        var mask = (1 << 8) - 1; 
        for(var i = 0; i < bin.length * 32; i += 8) 
            str += String.fromCharCode((bin[i>>5] >>> (i % 32)) & mask); 
        return str; 
    },
    
    /* 
     * Convert an array of little-endian words to a hex string. 
     */ 
    binl2hex : function(binarray, helper) { 
        var hexcase = 0; /* hex output format. 0 - lowercase; 1 - uppercase */ 
        var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef"; 
        var str = ""; 
        for(var i = 0; i < binarray.length * 4; i++) 
        { 
            str += hex_tab.charAt((binarray[i>>2] >> ((i%4)*8+4)) & 0xF) + 
                hex_tab.charAt((binarray[i>>2] >> ((i%4)*8 )) & 0xF); 
        } 
        return str; 
    },
    
    /* 
     * Convert an array of little-endian words to a base-64 string 
     */ 
    binl2b64 : function(binarray, helper) {
        var b64pad = ""; /* base-64 pad character. "=" for strict RFC compliance */ 
        var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; 
        var str = ""; 
        for(var i = 0; i < binarray.length * 4; i += 3) 
        { 
            var triplet = (((binarray[i >> 2] >> 8 * ( i %4)) & 0xFF) << 16) 
            | (((binarray[i+1 >> 2] >> 8 * ((i+1)%4)) & 0xFF) << 8 ) 
            | ((binarray[i+2 >> 2] >> 8 * ((i+2)%4)) & 0xFF); 
            for(var j = 0; j < 4; j++) 
            { 
                if(i * 8 + j * 6 > binarray.length * 32) str += b64pad; 
                else str += tab.charAt((triplet >> 6*(3-j)) & 0x3F); 
            } 
        } 
        return str; 
    },
    
    takeYear : function(theDate, helper) { 
        var x = theDate.getYear(); 
        var y = x % 100; 
        y += (y < 38) ? 2000 : 1900; 
        return y; 
    },
    
    GMTime : function(helper) { 
        var temp; 
        var mydate, myyear, mymonth, myday, myhour, mymin, mysec, myoffset; 
        temp = new Date().toGMTString(); 
        mydate = new Date(temp); 
        myoffset = mydate.getTimezoneOffset(); 
        mydate.setMinutes(mydate.getMinutes()+ myoffset); 
        myyear = helper.takeYear(mydate); 
        mymonth = mydate.getMonth()+1; 
        myday = mydate.getDate(); 
        myhour = mydate.getHours(); 
        mymin = mydate.getMinutes(); 
        mysec = mydate.getSeconds(); 
        
        return (mymonth + '/' + myday + '/' + myyear + ' ' + myhour + ':' + mymin + ':' + mysec) 
    },

})