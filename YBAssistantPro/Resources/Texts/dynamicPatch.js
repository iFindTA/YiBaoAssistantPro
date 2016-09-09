//在类里定义的 static 全局变量无法在 JS 上获取到，若要在 JS 拿到这个变量，需要在 OC 有类方法或实例方法把它返回

//Chat Cell Type For: text

defineClass('PBChatTextCell: PBChatBaseCell', {
   awakeFromNib: function() {
    self.initSetupSubClass();
    }, 
    initWithStyle_reuseIdentifier: function(style, reuseIdentifier) {
    self = self.super().initWithStyle_reuseIdentifier(style, reuseIdentifier);
    if (self) {
        self.initSetupSubClass();
    }
    return self;
    }, 
    initSetupSubClass: function() {

    self.contentView().addSubview(self.contentBtn());
    },
    layoutSubviews: function() {
    self.super().layoutSubviews();

    //weakify(self);
    //var slf = self;
    
    var dataFrame = self.dataSource().contentSize();
    var mW =  dataFrame.width;
    var mH = dataFrame.height;
    //console.log(mW, mH);
    var slf = __weak(self);
    self.contentBtn().mas__makeConstraints(block('MASConstraintMaker*', function(make) {
        make.top().equalTo()(slf.avatarBtn());
        if (slf.dataSource().isSelfSend()) {
            make.right().equalTo()(slf.avatarBtn().left()).offset()(-10);
        } else {
            make.left().equalTo()(slf.avatarBtn().right()).offset()(10);
        }
        //make.size().equalTo()({width:mW, height:mH});
        make.width().equalTo()(mW);
        make.height().equalTo()(mH);
    }));
    },
    updateCellContent4Frame: function(frame) {
    self.super().updateCellContent4Frame(frame);
    self.layoutIfNeeded();
    //filling content
    self.contentBtn().setIsSelfMsg(frame.isSelfSend());
    // //隐藏语音、图片背景
    self.contentBtn().cBubble().setHidden(true);
    self.contentBtn().cAudioBgView().setHidden(true);
    self.contentBtn().setTitle_forState(frame.displayText(), 0);

    }
});