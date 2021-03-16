function a(all){
    let _all=0;
    for(let i=0;i<1000;i++){
        _all+=all
        all=all*((100-10)/100)
    }
    return _all;
}


console.log(a(1))