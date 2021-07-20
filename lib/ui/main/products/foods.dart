import 'dart:math';
import 'package:delivery_owner/config/api.dart';
import 'package:delivery_owner/model/server/category.dart';
import 'package:delivery_owner/model/server/categoryDelete.dart';
import 'package:delivery_owner/model/server/categorySave.dart';
import 'package:delivery_owner/model/server/extras.dart';
import 'package:delivery_owner/model/server/extrasDelete.dart';
import 'package:delivery_owner/model/server/extrasGroupDelete.dart';
import 'package:delivery_owner/model/server/extrasGroupSave.dart';
import 'package:delivery_owner/model/server/extrasSave.dart';
import 'package:delivery_owner/model/server/foodDelete.dart';
import 'package:delivery_owner/model/server/foodSave.dart';
import 'package:delivery_owner/model/server/foods.dart';
import 'package:delivery_owner/model/server/uploadImage.dart';
import 'package:delivery_owner/model/server/variantAdd.dart';
import 'package:delivery_owner/model/server/variantsDelete.dart';
import 'package:delivery_owner/model/util.dart';
import 'package:delivery_owner/ui/widgets/colorloader2.dart';
import 'package:delivery_owner/ui/widgets/easyDialog2.dart';
import 'package:delivery_owner/ui/widgets/ibutton3.dart';
import 'package:delivery_owner/ui/widgets/ibutton3withId.dart';
import 'package:delivery_owner/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:delivery_owner/main.dart';
import 'package:image_picker/image_picker.dart';

class FoodsScreen extends StatefulWidget {
  final Function(String) callback;
  FoodsScreen({Key key, this.callback}) : super(key: key);

  @override
  _FoodsScreenState createState() => _FoodsScreenState();
}

/*
      initState()
        _loadCategoryList()
        _loadFoodsList()
        _loadExtrasList()

      // screens
      _bodyRoot()
          _viewCategoryList()               // category
              _addCategory()
                  _addNewCategory()
                      _catSave()
              _editCategory()
              _deleteCategory()
          _viewFoodList()                   // food
              _addFood()
                    _addNewFood()
                        _foodSave()
              _editFood()
              _deleteFood()
          _viewExtrasGroupList()            // extras group
              _addExtrasGroup
                    _addNewExtrasGroup
                        _extrasGroupSave
              _editExtrasGroup
              _deleteExtrasGroup()

          _viewExtrasList()            // extras
              _addExtras();
                    _addNewExtras
                      _extrasSave
                        _extrasSave2
              _editExtras
              _deleteExtras()

          _nutritionComboBoxInForm
          _extrasComboBoxInForm
          _restaurantsComboBoxInForm
          _categoryComboBoxInForm

      _onBack()
      _changeState()
      _clearVariables()

      dialogs:
        _openDialogError()
        _makeImageDialog()
        _deleteDialog()
        _filterDialog()
            _categoryComboBox()
            _restaurantsComboBox()

 */

class ImageFilesData{
  String id = "0";
  String localFile;
  String serverFile;

  ImageFilesData(this.id, this.localFile, this.serverFile);
}

class _FoodsScreenState extends State<FoodsScreen> {

  double windowWidth = 0.0;
  double windowHeight = 0.0;
  List<ImageData> _image;
  List<CategoriesData> _cat;
  List<FoodsData> _foods;
  List<RestaurantData> _restaurants;
  List<ExtrasGroupData> _extrasGroup;
  List<NutritionGroupData> _nutritionGroup;
  List<ExtrasData> _extras;
  int _numberOfDigits;
  var editControllerName = TextEditingController();
  var editControllerPrice = TextEditingController();
  var editControllerDiscountPrice = TextEditingController();
  var editControllerDesc = TextEditingController();
  var editControllerIngredients = TextEditingController();
  var editControllerVariantsName = TextEditingController();
  var editControllerVariantsPrice = TextEditingController();
  var editControllerVariantsDiscountPrice = TextEditingController();
  var _categoryValueOnForm = 0;
  var _restaurantValueOnForm = 0;
  var _extrasGroupValueOnForm = 0;
  var _nutritionGroupValueOnForm = 0;
  var _published = true;
  List<ImageFilesData> _imagesFiles = [];
  // List<String> _imagePath = [];
  // List<String> _serverImagePath = [];
  // List<String> _imageId = [];
  bool _wait = false;
  String _searchValue = "";
  var _editItem = false;
  var _editItemId = "";
  var _ensureVisibleId = "";
  var scrollController = ScrollController();
  final picker = ImagePicker();

  GlobalKey itemKey = GlobalKey();

  @override
  void initState() {
    _loadCategoryList();
    _loadFoodsList();
    if (theme.extras)
      _loadExtrasList();
    super.initState();
  }

  @override
  void dispose() {
    editControllerName.dispose();
    editControllerDesc.dispose();
    editControllerPrice.dispose();
    editControllerDiscountPrice.dispose();
    editControllerIngredients.dispose();
    editControllerVariantsName.dispose();
    editControllerVariantsPrice.dispose();
    editControllerVariantsDiscountPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () async {
      if (_show != 0) {
        setState(() {
          _show = 0;
        });
        return false;
      }
      _onBack();
      return false;
    },
    child: Stack(

      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top+50, left: 15, right: 15),
            child: ListView(
              padding: EdgeInsets.only(top: 0),
              controller: scrollController,
          children: _body(),
        )),

        buttonBack(_onBack),

        if (_wait)
            Container(
              color: Color(0x80000000),
              width: windowWidth,
              height: windowHeight,
              child: Container(
                alignment: Alignment.center,
                child: ColorLoader2(
                  color1: theme.colorPrimary,
                  color2: theme.colorCompanion,
                  color3: theme.colorPrimary,
                ),
              ),
            ),

        IEasyDialog2(setPosition: (double value){_show = value;}, getPosition: () {return _show;}, color: theme.colorGrey,
          body: _dialogBody, backgroundColor: theme.colorBackground,),

      ],
    ));
  }

  _waits(bool value) {
    _wait = value;
    if (mounted)
      setState(() {
      });
  }

  _getImage(int imageid){
    if (_image != null)
      for(var item in _image)
        if (item.id == imageid)
          return "$serverImages${item.filename}";
    return serverImgNoImage;
  }

  _onBack(){
    if (_state == "root")
      return widget.callback("home");

    // category
    if (_state == "viewCategoryList")
      _state = "root";
    if (_state == "addCategory")
      _state = "root";
    if (_state == "editCategory")
      _state = "viewCategoryList";

    // foods
    if (_state == "viewFoodsList")
      _state = "root";
    if (_state == "addFood")
      _state = "root";
    if (_state == "editFood")
      _state = "viewFoodsList";

    // extras group
    if (_state == "viewExtrasGroupList")
      _state = "root";
    if (_state == "editExtrasGroup")
      _state = "viewExtrasGroupList";
    if (_state == "addExtrasGroup")
      _state = "root";

    // extras
    if (_state == "viewExtrasList")
      _state = "root";
    if (_state == "editExtras")
      _state = "viewExtrasList";
    if (_state == "addExtras")
      _state = "root";

    setState(() {});
  }

  var _state = "root";
  var _lastState = "root";
  _body(){
    switch(_state){
      case "viewFoodsList":
        return _viewFoodList();
      break;
      case "addFood":
        return _addFood();
        break;
      case "editFood":
        return _addFood();
        break;
      case "viewCategoryList":
        return _viewCategoryList();
        break;
      case "viewExtrasGroupList":
        return _viewExtrasGroupList();
        break;
      case "addCategory":
        return _addCategory();
        break;
      case "editCategory":
        return _addCategory();
        break;
      case "addExtrasGroup":
        return _addExtrasGroup();
        break;
      case "editExtrasGroup":
        return _addExtrasGroup();
        break;
      case "viewExtrasList":
        return _viewExtrasList();
        break;
      case "addExtras":
        return _addExtras();
        break;
      case "editExtras":
        return _addExtras();
        break;
      default:
        return _bodyRoot();
    }
  }

  _changeState(String state){
    if (state != _lastState){
      _state = state;
      _clearVariables();
      setState(() {
      });
    }
  }

  _clearVariables(){
    editControllerName.text = "";
    editControllerDesc.text = "";
    editControllerPrice.text = "";
    editControllerDiscountPrice.text = "";
    editControllerIngredients.text = "";
    _searchPublished = true;
    _searchHidden = true;
    _published = true;
    _imagesFiles = [];
    // _imagePath = [];
    // _serverImagePath = [];
    // _imageId = [];
    _editItem = false;
    _editItemId = "";
    _searchValue = "";
    _categoryValueOnForm = 0;
    _restaurantValueOnForm = 0;
    _extrasGroupValueOnForm = 0;
    _nutritionGroupValueOnForm = 0;
    _ensureVisibleId = "";
    _variantEdit = null;
    editControllerVariantsName.text = "";
    editControllerVariantsPrice.text = "";
    editControllerVariantsDiscountPrice.text = "";
    _imageFileVariants = ImageFilesData("", "", "");
    _cacheVariants = [];
  }

  String _vendor;
  _loadCategoryList(){
    categoryLoad(account.token, (List<ImageData> image, List<CategoriesData> cat, String vendor){
      _image = image;
      _cat = cat;
      _vendor = vendor;
      setState(() {});
    }, _openDialogError);
  }

  _loadExtrasList(){
    extrasLoad(account.token, (List<ImageData> image, List<ExtrasData> extras){
      _image = image;
      _extras = extras;
      setState(() {});
    }, _openDialogError);
  }

  _loadFoodsList(){
    foodsLoad(account.token,
            (List<ImageData> image, List<FoodsData> foods, List<RestaurantData> restaurants,
            List<ExtrasGroupData> extrasGroup, List<NutritionGroupData> nutritionGroup, int numberOfDigits){
      _image = image;
      _foods = foods;
      _restaurants = restaurants;
      _extrasGroup = extrasGroup;
      _nutritionGroup = nutritionGroup;
      _numberOfDigits = numberOfDigits;
      setState(() {});
    }, _openDialogError);
  }

  double _show = 0;
  Widget _dialogBody = Container();
  _openDialogError(String _text) {
    _waits(false);
    if (_text == '5') // You have no permissions
      _text = strings.get(250);
    if (_text == '6') // This is demo application. Your can not modify this section.
      _text = strings.get(248);
    _dialogBody = Column(
      children: [
        Text(_text, style: theme.text14,),
        SizedBox(height: 40,),
        IButton3(
            color: theme.colorPrimary,
            text: strings.get(66),              // Cancel
            textStyle: theme.text14boldWhite,
            pressButton: (){
              setState(() {
                _show = 0;
              });
            }
        ),
      ],
    );
    setState(() {
      _show = 1;
    });
  }

  _searchBar(){
    return formSearch((String value){
        _searchValue = value.toUpperCase();
        _ensureVisibleId = "";
        setState(() {});
      });
  }

  _viewFoodList(){
      List<Widget> list = [];
      var _needShow = 0.0;
      if (_foods != null){
        list.add(_titlePath("${strings.get(94)} > ${strings.get(94)}"));  // "Foods",  // "Foods",
        list.add(_searchBar());  // Search
        list.add(Row(children: [
          checkBox(strings.get(174), _searchPublished, (bool value){
            _searchPublished = value;
            setState(() {});
          }),  // "PUBLISHED",
          checkBox(strings.get(175), _searchHidden, (bool value){
            _searchHidden = value;
            setState(() {});
          }),  // "HIDDEN",
        ],));
        list.add(_categoryComboBox());
        list.add(Container(
            width: windowWidth,
            child: Text(strings.get(146), style: theme.text12bold, textAlign: TextAlign.start,),                // Choose Food Category
            ));
        if (theme.multiple){
          list.add(_restaurantsComboBox());
          list.add(Container(
              width: windowWidth,
              child: Text(strings.get(179), style: theme.text12bold, textAlign: TextAlign.start,),                // "Choose Restaurant",
              ));
        }

        list.add(SizedBox(height: 20,));
        var count = 0;
        for (var item in _foods){
          if (!_searchPublished && item.visible == '1')
            continue;
          if (!_searchHidden && item.visible == '0')
            continue;
          if (_categoryValue != 0 && item.category != _categoryValue)
            continue;
          if (_restaurantValue != 0 && item.restaurant != _restaurantValue)
            continue;
          if (item.name.toUpperCase().contains(_searchValue)){
            if (_ensureVisibleId == item.id.toString()) {
              if (count > 0)
                _needShow = 60.0+(290)*count-290;//-290;
              else
                _needShow = 60.0+(290)*count;
              dprint("${item.id} $count");
            }
            count++;
            list.add(Container(
              height: 120+90.0,
              child: oneItem("${strings.get(163)}${item.id}", item.name, "${strings.get(164)}${item.updatedAt}", _getImage(item.imageid),
                windowWidth, item.visible),)
                ); // "Last update: ",
            list.add(SizedBox(height: 10,));
            list.add(Container(
              height: 50,
                child: buttonsEditOrDelete(item.id.toString(), _editFood, _deleteDialog, windowWidth)));
            list.add(SizedBox(height: 20,));
          }
        }
      }
      if (_needShow != null && _ensureVisibleId != "")
        Future.delayed(const Duration(milliseconds: 100), () {
           scrollController.jumpTo(_needShow+100);
          Future.delayed(const Duration(milliseconds: 100), () {
            scrollController.animateTo(_needShow, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
          });
        });

      dprint("_needShow = $_needShow");
      list.add(SizedBox(height: 200,));
      return list;
  }

  _titlePath(String text){
    return Container(
      child: Text(text, style: theme.text14),
    );
  }

  _viewCategoryList(){
    List<Widget> list = [];
    list.add(_titlePath("${strings.get(94)} > ${strings.get(135)}"));  // "Foods",  // "Category",
    list.add(_searchBar());  // Search
    list.add(Row(children: [
      checkBox(strings.get(174), _searchPublished, (bool value){
        _searchPublished = value;
        setState(() {});
      }),  // "PUBLISHED",
      checkBox(strings.get(175), _searchHidden, (bool value){
        _searchHidden = value;
        setState(() {});
      }),  // "HIDDEN",
    ],));
    list.add(SizedBox(height: 20,));
    var _needShow = 0.0;
    if (_cat != null){
      var count = 0;
      for (var item in _cat){
        if (!_searchPublished && item.visible == '1')
          continue;
        if (!_searchHidden && item.visible == '0')
          continue;
        if (!item.name.toUpperCase().contains(_searchValue))
          continue;
        if (theme.appTypePre == "multivendor" && item.vendor != _vendor)
          continue;
        if (_ensureVisibleId == item.id.toString()) {
          if (count > 0)
            _needShow = 60.0+(290)*count-290;//-290;
          else
            _needShow = 0;
          dprint("${item.id} $count");
        }
        count++;
        list.add(Container(
            height: 120+90.0,
            child: oneItem("${strings.get(163)}${item.id}", item.name, "${strings.get(164)}${item.updatedAt}", _getImage(item.imageid),
            windowWidth, item.visible))); // "Last update: ",
        list.add(SizedBox(height: 10,));
        list.add(Container(
            height: 50,
            child: buttonsEditOrDelete(item.id.toString(), _editCategory, _deleteDialog, windowWidth)
        ));
        list.add(SizedBox(height: 20,));
      }
    }
    dprint("_needShow $_needShow");
    if (_needShow != null && _ensureVisibleId != "")
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_needShow < 0) _needShow = 0;
        scrollController.jumpTo(_needShow+100);
        Future.delayed(const Duration(milliseconds: 100), () {
          scrollController.animateTo(_needShow, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
        });
      });

    list.add(SizedBox(height: 200,));
    return list;
  }

  _viewExtrasList(){
    List<Widget> list = [];
    list.add(_titlePath("${strings.get(94)} > ${strings.get(199)}"));  // "Foods",  // "Extras",
    list.add(_searchBar());  // Search
    list.add(_extrasGroupComboBox());
    list.add(SizedBox(height: 20,));
    var _needShow = 0.0;
    if (_extras != null){
      var count = 0;
      for (var item in _extras){
        if (!item.name.toUpperCase().contains(_searchValue))
          continue;
        if (_extrasGroupValue != 0 && item.extrasGroup != _extrasGroupValue)
          continue;
        if (_ensureVisibleId == item.id.toString()) {
          if (count > 0)
            _needShow = 60.0+(290)*count-290;//-290;
          else
            _needShow = 0;
          dprint("${item.id} $count");
        }
        count++;
        list.add(Container(
            height: 120+90.0,
            child: oneItem("${strings.get(163)}${item.id}", item.name, "${strings.get(164)}${item.updatedAt}", _getImage(item.imageid),
                windowWidth, '1'))); // "Last update: ",
        list.add(SizedBox(height: 10,));
        list.add(Container(
            height: 50,
            child: buttonsEditOrDelete(item.id.toString(), _editExtras, _deleteDialog, windowWidth)
        ));
        list.add(SizedBox(height: 20,));
      }
    }
    dprint("_needShow $_needShow");
    if (_needShow != null && _ensureVisibleId != "")
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_needShow < 0) _needShow = 0;
        scrollController.jumpTo(_needShow+100);
        Future.delayed(const Duration(milliseconds: 100), () {
          scrollController.animateTo(_needShow, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
        });
      });

    list.add(SizedBox(height: 200,));
    return list;
  }

  _editExtras(String id){
    for (var item in _extras)
      if (item.id.toString() == id) {
        editControllerName.text = item.name;
        editControllerPrice.text = item.price;
        editControllerDesc.text = item.desc;
        _imagesFiles = [];
        // _imagePath = [];
        // _serverImagePath = [];
        for (var image in _image)
          if (image.id == item.imageid) {
            _imagesFiles.add(ImageFilesData(image.id.toString(), "", "$serverImages${image.filename}"));
            // _serverImagePath.add("$serverImages${image.filename}");
            // _imageId.add(image.id.toString());
          }
        for (var ex in _extrasGroup)
          if (ex.id == item.extrasGroup)
            _extrasGroupValueOnForm = item.extrasGroup;
        _state = "editExtras";
        _editItem = true;
        _editItemId = id;
        setState(() {});
      }
  }

  _viewExtrasGroupList(){
    List<Widget> list = [];
    list.add(_titlePath("${strings.get(94)} > ${strings.get(195)}"));  // "Foods",  // "Extras Groups",
    list.add(_searchBar());  // Search
    list.add(SizedBox(height: 20,));
    var _needShow = 0.0;
    if (_extrasGroup != null){
      var count = 0;
      for (var item in _extrasGroup){
        if (!item.name.toUpperCase().contains(_searchValue))
          continue;
        if (_ensureVisibleId == item.id.toString()) {
          if (count > 0)
            _needShow = 60.0+(290)*count-290;//-290;
          else
            _needShow = 0;
          dprint("${item.id} $count");
        }
        count++;
        list.add(Container(
            height: 120+90.0,
            child: oneItem("${strings.get(163)}${item.id}", item.name, "${strings.get(164)}${item.updatedAt}", serverImgNoImage,
                windowWidth, '1'))); // "Last update: ",
        list.add(SizedBox(height: 10,));
        list.add(Container(
            height: 50,
            child: buttonsEditOrDelete(item.id.toString(), _editExtrasGroup, _deleteDialog, windowWidth)
        ));
        list.add(SizedBox(height: 20,));
      }
    }
    dprint("_needShow $_needShow");
    if (_needShow != null && _ensureVisibleId != "")
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_needShow < 0) _needShow = 0;
        scrollController.jumpTo(_needShow+100);
        Future.delayed(const Duration(milliseconds: 100), () {
          scrollController.animateTo(_needShow, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
        });
      });

    list.add(SizedBox(height: 200,));
    return list;
  }

  _editCategory(String id){
    for (var item in _cat)
      if (item.id.toString() == id) {
        editControllerName.text = item.name;
        editControllerDesc.text = item.desc;
        _categoryValue = item.parent;
        if (item.visible == '1') _published = true; else _published = false;
        // _imagePath = [];
        // _serverImagePath = [];
        _imagesFiles = [];
        for (var image in _image)
          if (image.id == item.imageid) {
            _imagesFiles.add(ImageFilesData(image.id.toString(), "", "$serverImages${image.filename}"));
            // _serverImagePath.add("$serverImages${image.filename}");
            // _imageId.add(image.id.toString());
          }
        _state = "editCategory";
        _editItem = true;
        _editItemId = id;
        setState(() {});
      }
  }

  _editFood(String id){
    _clearVariables();
    for (var item in _foods)
      if (item.id.toString() == id) {
        editControllerName.text = item.name;
        editControllerDesc.text = item.desc;
        editControllerPrice.text = item.price;
        editControllerDiscountPrice.text = item.discountprice;
        for (var ex in _restaurants)
          if (ex.id == item.restaurant)
            _restaurantValueOnForm = item.restaurant;
        for (var ex in _cat)
          if (ex.id == item.category)
            _categoryValueOnForm = item.category;
        if (_extrasGroup != null)
          for (var ex in _extrasGroup)
              if (ex.id == item.extras)
                _extrasGroupValueOnForm = item.extras;
        if (_nutritionGroup != null)
          for (var ex in _nutritionGroup)
            if (ex.id == item.nutrition)
              _nutritionGroupValueOnForm = item.nutrition;

        editControllerIngredients.text = item.ingredients;
        if (item.visible == '1') _published = true; else _published = false;
        // _imagePath = [];
        // _serverImagePath = [];
        // _imageId = [];
        _imagesFiles = [];
        for (var image in _image)
          if (image.id == item.imageid) {
            _imagesFiles.add(ImageFilesData(image.id.toString(), "", "$serverImages${image.filename}"));
            // _serverImagePath.add("$serverImages${image.filename}");
            // _imageId.add(image.id.toString());
          }
        for (var item in item.imagesFilesIds){
          for (var image in _image)
            if (image.id.toString() == item) {
              _imagesFiles.add(ImageFilesData(image.id.toString(), "", "$serverImages${image.filename}"));
              // _serverImagePath.add("$serverImages${image.filename}");
              // _imageId.add(image.id.toString());
            }
        }

        _state = "editFood";
        _editItem = true;
        _editItemId = id;
        setState(() {});
      }
  }

  _editExtrasGroup(String id){
    for (var item in _extrasGroup)
      if (item.id.toString() == id) {
        editControllerName.text = item.name;
        _restaurantValueOnForm = 0;
        for (var ex in _restaurants)
          if (ex.id == item.restaurant)
            _restaurantValueOnForm = item.restaurant;
        _state = "editExtrasGroup";
        _editItem = true;
        _editItemId = id;
        setState(() {});
      }
  }

  _deleteCategory(String id){
    categoryDelete(id,
      (List<ImageData> image, List<CategoriesData> cat) {
      _image = image; _cat = cat;
      _waits(false);
      setState(() {});
    }, _openDialogError);
  }

  _deleteFood(String id){
    foodDelete(id,
            (List<ImageData> image, List<FoodsData> foods, List<RestaurantData> restaurants,
                List<ExtrasGroupData> extrasGroup, List<NutritionGroupData> nutritionGroup) {
              _image = image;
              _foods = foods;
              _restaurants = restaurants;
              _extrasGroup = extrasGroup;
              _nutritionGroup = nutritionGroup;
              _waits(false);
        }, _openDialogError);
  }

  _deleteExtrasGroup(String id){
    extrasGroupDelete(id,
            (List<ExtrasGroupData> extrasGroup, ) {
          _extrasGroup = extrasGroup;
          _waits(false);
        }, _openDialogError);
  }

  _deleteExtras(String id){
    extrasDelete(id,
            (List<ImageData> image, List<ExtrasData> extras) {
          _extras = extras;
          _image = image;
          _waits(false);
          setState(() {
          });
        }, _openDialogError);
  }

  _addFood(){
    List<Widget> list = [];
    list.add(_titlePath((_editItem) ? "${strings.get(94)} > ${strings.get(94)} > ${strings.get(108)}" :
            "${strings.get(94)} > ${strings.get(94)} > ${strings.get(200)}"));  // "Foods",  // "Foods", Edit Add
    list.add(SizedBox(height: 20,));
    list.add(Text((_editItem) ? strings.get(202) : strings.get(181), style: theme.text16bold, textAlign: TextAlign.center,));  // "Add New Food",
    list.add(SizedBox(height: 20,));
    list.add(formEdit(strings.get(113), editControllerName, "", 100)); // Name
    list.add(Row(children: [
        Text(strings.get(182), style: theme.text12bold,),  // "Enter Food name"
      SizedBox(width: 4,),
      Text("*", style: theme.text28Red)
    ],));

    list.add(SizedBox(height: 20,));
    list.add(formEditPrice(strings.get(183), editControllerPrice, "", _numberOfDigits)); // Price -
    list.add(Row(children: [
      Text(strings.get(184), style: theme.text12bold,),  //  "Enter Price",
      SizedBox(width: 4,),
      Text("*", style: theme.text28Red)
    ],));

    list.add(SizedBox(height: 20,));
    list.add(formEditPrice(strings.get(256), editControllerDiscountPrice, "", _numberOfDigits)); // Discount Price
    list.add(Row(children: [
      Text(strings.get(257), style: theme.text12bold,),  //  "Enter Discount Price",
      SizedBox(width: 4,),
      Text("*", style: theme.text28Red)
    ],));

    list.add(SizedBox(height: 20,));
    list.add(_categoryComboBoxInForm());
    list.add(Row(children: [
      Text(strings.get(185), style: theme.text12bold,),  //  "Select Category"
      SizedBox(width: 4,),
      Text("*", style: theme.text28Red)
    ],));
    list.add(SizedBox(height: 20,));

    if (theme.multiple){
      list.add(_restaurantsComboBoxInForm());
      list.add(Row(children: [
        Text(strings.get(186), style: theme.text12bold,),  //  "Select Restaurant"
        SizedBox(width: 4,),
        Text("*", style: theme.text28Red)
      ],));
      list.add(SizedBox(height: 20,));
    }else
      _restaurantValueOnForm = 1;

    list.add(formEdit(strings.get(169), editControllerDesc, strings.get(170), 250)); // Description - "Enter description",
    list.add(SizedBox(height: 20,));
    list.add(formEdit(strings.get(187), editControllerIngredients, strings.get(188), 250)); // Ingredients - "Enter Ingredients",
    list.add(SizedBox(height: 20,));
    if (theme.extras){
      list.add(_extrasComboBoxInForm());
      list.add(Text(strings.get(191), style: theme.text12bold,));           // "Select Extras"
      list.add(SizedBox(height: 20,));
      list.add(_nutritionComboBoxInForm());
      list.add(Text(strings.get(190), style: theme.text12bold,));           // "Select Nutritions"
      list.add(SizedBox(height: 20,));
    }
    list.add(selectImage(windowWidth, _makeImageDialog, theme.colorGrey, Colors.black.withAlpha(150)));         // select image
    list.add(SizedBox(height: 20,));
    // Images
    list.add(Text(strings.get(173), style: theme.text14, textAlign: TextAlign.start,));  // "Current Image",
    list.add(SizedBox(height: 20,));
    for (var file in _imagesFiles){
      if (file.localFile.isNotEmpty)
        list.add(Container(child: drawImageLocal(file.localFile, windowWidth, true, _deleteServerImage, file.id)));
      if (file.serverFile.isNotEmpty)
        list.add(Container(child: drawImageServer(file.serverFile, windowWidth, true, _deleteServerImage, file.id)));
    }

    //
    // Variants
    //
    list.add(SizedBox(height: 30,));
    List<Widget> list3 = [];
    list3.add(SizedBox(height: 10,));
    list3.add(Container(
        width: windowWidth,
        child: Text(strings.get(259), style: theme.text16bold, textAlign: TextAlign.center,)  // "Variants",
    ));
    list3.add(SizedBox(height: 10,));
    if (_editItem)
      for (var item in _foods)
        if (_editItemId == item.id){
          for (var vitem in item.variants)
            _addItemVariant(list3, vitem);
        }
    for (var vitem in _cacheVariants)
      _addItemVariant(list3, vitem);

    list.add(Container(
      color: Colors.cyan.withAlpha(50),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list3,
      ),
    ));
    list.add(SizedBox(height: 10,));
    List<Widget> list2 = [];
    list2.add(SizedBox(height: 10,));
    list2.add(Container(
      width: windowWidth,
      child: Text((_variantEdit != null) ? strings.get(264) : strings.get(261), style: theme.text16bold, textAlign: TextAlign.center,)  // Edit variant - Add variant
    ));
    list2.add(SizedBox(height: 20,));
    list2.add(formEdit(strings.get(113), editControllerVariantsName, "", 100)); // Name
    list2.add(Text(strings.get(260), style: theme.text12bold,),);  // "Enter Variant name"
    list2.add(SizedBox(height: 20,));
    list2.add(formEditPrice(strings.get(183), editControllerVariantsPrice, "", _numberOfDigits)); // Price -
    list2.add(Text(strings.get(184), style: theme.text12bold,),);  //  "Enter Price",
    list2.add(SizedBox(height: 20,));
    list2.add(formEditPrice(strings.get(256), editControllerVariantsDiscountPrice, "", _numberOfDigits)); // Discount Price
    list2.add(Text(strings.get(257), style: theme.text12bold,),);  //  "Enter Discount Price",
    list2.add(SizedBox(height: 20,));
    list2.add(selectImage(windowWidth, _makeImageDialogVariants, Colors.cyan.withAlpha(200), Colors.white));        // select image
    list2.add(SizedBox(height: 10,));
    list2.add(Text(strings.get(173), style: theme.text14, textAlign: TextAlign.start,));                    // "Current Image",
    list2.add(SizedBox(height: 20,));
    if (_imageFileVariants.localFile.isNotEmpty)
      list2.add(Container(child: drawImageLocal(_imageFileVariants.localFile, windowWidth, false, _deleteServerImage, _imageFileVariants.id)));
    if (_imageFileVariants.serverFile.isNotEmpty)
      list2.add(Container(child: drawImageServer(_imageFileVariants.serverFile, windowWidth, false, _deleteServerImage, _imageFileVariants.id)));
    list2.add(SizedBox(height: 10,));
    list2.add(Container(
      padding: EdgeInsets.all(10),
      child: IButton3(color: Colors.cyan.withAlpha(200),
          text: (_variantEdit != null) ? strings.get(267) : strings.get(261),              // Save variant - Add variant
          textStyle: theme.text14boldWhite,
          pressButton: _addNewVariant
      ),));
    list.add(Container(
      key: itemKey,
      color: Colors.cyan.withAlpha(50),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list2,
      ),
    ));


    // for (var file in _imagePath)
    //   list.add(Container(child: drawImageLocal(file, windowWidth, true)));
    // for (var file in _serverImagePath)
    //   list.add(Container(child: drawImageServer(file, windowWidth, true, _deleteServerImage)));
    //
    list.add(SizedBox(height: 20,));
    list.add(checkBox(strings.get(171), _published, (bool value){setState(() {_published = value;});}));                      // "Published item",
    list.add(SizedBox(height: 20,));
    list.add(IButton3(color: theme.colorPrimary,
        text: strings.get(65),              // Save
        textStyle: theme.text14boldWhite,
        pressButton: _addNewFood
    ));

    list.add(SizedBox(height: 150,));
    return list;
  }

  _addItemVariant(List<Widget> list3, VariantsData vitem){
    var _image = _getImage(vitem.imageId);
    list3.add(Container(
        padding: EdgeInsets.all(10),
        color: Colors.cyan.withAlpha(70),
        child: Row(
          children: [
            Expanded(child: Text(vitem.name, style: theme.text16bold,)),
            Expanded(child: Text(makePrice(vitem.price))),
            Expanded(child: Text(makePrice(vitem.dprice))),
            Container(child: drawImageServer2(_image))
          ],
        )
    ));
    list3.add(Container(
        padding: EdgeInsets.all(10),
        color: Colors.cyan.withAlpha(70),
        child: Row(
          children: [
            Expanded(child: IButton3withId(color: Colors.cyan.withAlpha(200),
                id: vitem.id.toString(),
                text: strings.get(264),              // Edit variant
                textStyle: theme.text14boldWhite,
                pressButton: _editVariant
            )),
            SizedBox(width: 10,),
            Expanded(child: IButton3withId(color: Colors.red.withAlpha(200),
                id: vitem.id.toString(),
                text: strings.get(263),              // Delete variant
                textStyle: theme.text14boldWhite,
                pressButton: _deleteVariant
            )),
          ],
        )
    ));
    list3.add(SizedBox(height: 10,));
  }

  VariantsData _variantEdit;

  _editVariant(String id){
    for (var item in _foods)
      if (_editItemId == item.id) {
        for (var vitem in item.variants){
          if (vitem.id.toString() == id){
              _variantEdit = vitem;
              editControllerVariantsName.text = vitem.name;
              editControllerVariantsPrice.text = vitem.price.toString();
              editControllerVariantsDiscountPrice.text = vitem.dprice.toString();
              _imageFileVariants = ImageFilesData(vitem.imageId.toString(), "", _getImage(vitem.imageId));
              setState(() {
              });
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn);
              Future.delayed(const Duration(milliseconds: 1000), () {
                scrollController.position.ensureVisible(
                  itemKey.currentContext.findRenderObject(),
                  alignment: 0.5, // How far into view the item should be scrolled (between 0 and 1).
                  duration: const Duration(seconds: 1),
                );
              });
          }
        }
      }
  }

  _deleteVariant(String id){
    variantsDelete(id, _editItemId,
        (){
          for (var item in _foods)
            if (_editItemId == item.id) {
              var tempItem;
              for (var vitem in item.variants)
                if (vitem.id.toString() == id){
                  tempItem = vitem;
                  break;
                }
              if (tempItem != null) {
                item.variants.remove(tempItem);
                if (_variantEdit == null)
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(strings.get(266)), // Variant deleted
                    duration: Duration(seconds: 10),
                  ));
              }
            }
          _waits(false);
        }, _openDialogError);
  }

  _makeImageDialogVariants(){
    _dialogBody = Container(
        width: windowWidth,
        child: Column(
          children: [
            Text(strings.get(126), textAlign: TextAlign.center, style: theme.text18boldPrimary,), // "Select image from",
            SizedBox(height: 50,),
            Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: windowWidth/2-25,
                        child: IButton3(
                            color: theme.colorPrimary,
                            text: strings.get(127), // "Camera",
                            textStyle: theme.text14boldWhite,
                            pressButton: (){
                              setState(() {
                                _show = 0;
                              });
                              getImageVariants(ImageSource.camera);
                            }
                        )),
                    SizedBox(width: 10,),
                    Container(
                        width: windowWidth/2-25,
                        child: IButton3(
                            color: theme.colorPrimary,
                            text: strings.get(128), // Gallery
                            textStyle: theme.text14boldWhite,
                            pressButton: (){
                              setState(() {
                                _show = 0;
                              });
                              getImageVariants(ImageSource.gallery);
                            }
                        )),
                  ],
                )),
          ],
        )
    );
    setState(() {
      _show = 1;
    });
  }

  ImageFilesData _imageFileVariants = ImageFilesData("", "", "");

  Future getImageVariants(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null && pickedFile.path != null) {
      print("Photo file: ${pickedFile.path}");
      _imageFileVariants = ImageFilesData("", pickedFile.path, "");
      setState(() {
      });
    }
  }

  _addNewVariant() async {
    if (editControllerVariantsName.text.isEmpty)
      return _openDialogError(strings.get(172));  // "The Name field is request",
    if (editControllerVariantsPrice.text.isEmpty)
      return _openDialogError(strings.get(194));  // "The Price field is request",

    _waits(true);

    if (_imageFileVariants.localFile.isNotEmpty)
      _imageFileVariants.id = await uploadImage(_imageFileVariants.localFile, account.token, (String path, String id) {
        _image.add(ImageData(id: toInt(id), filename: path));
      }, _openDialogError);

    if (_editItemId != ""){
      _variantsSave(_editItemId, editControllerVariantsName.text, editControllerVariantsPrice.text,
          editControllerVariantsDiscountPrice.text, _imageFileVariants.id);
      if (_variantEdit != null)
        _deleteVariant(_variantEdit.id.toString());
      _variantEdit = null;
    }else{
      _cacheVariants.add(VariantsData(id: 0, name: editControllerVariantsName.text, imageId: toInt(_imageFileVariants.id),
          price: toDouble(editControllerVariantsPrice.text), dprice: toDouble(editControllerVariantsDiscountPrice.text)));
      _waits(false);
    }
  }

  List<VariantsData> _cacheVariants = [];

  _variantsSave(String productId, String name, String price, String dprice, String imageid){
    if (imageid == "")
      imageid = "0";
      variantAdd(productId, name, price, dprice, imageid,
          account.token, (int id) {
          _waits(false);
          for (var item in _foods)
            if (_editItemId == item.id)
              item.variants.add(VariantsData(id: id, name: name, imageId: toInt(_imageFileVariants.id),
                  price: toDouble(price), dprice: toDouble(dprice)));
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(strings.get(265)), // Variant added
            duration: Duration(seconds: 10),
          ));
        }, _openDialogError);
  }

  _deleteServerImage(String id){
    for (var file in _imagesFiles) {
      if (file.id == id) {
        _imagesFiles.remove(file);
        break;
      }
    }
    setState(() {

    });
  }

  _addExtrasGroup(){
    List<Widget> list = [];
    list.add(_titlePath((_editItem) ? "${strings.get(94)} > ${strings.get(195)} > ${strings.get(108)}" :
          "${strings.get(94)} > ${strings.get(195)} > ${strings.get(200)}"));  // "Foods",  // Extras Groups", Edit Add
    list.add(SizedBox(height: 20,));
    if (_editItem)
      list.add(Text(strings.get(196), style: theme.text16bold, textAlign: TextAlign.center,));  // "Edit Extras Groups",
    else
      list.add(Text(strings.get(197), style: theme.text16bold, textAlign: TextAlign.center,));  // "Add New Extras Groups",
    list.add(SizedBox(height: 20,));
    list.add(formEdit(strings.get(113), editControllerName, "", 100)); // Name
    list.add(Row(children: [
      Text(strings.get(198), style: theme.text12bold,),  // "Enter Extras Group Name"
      SizedBox(width: 4,),
      Text("*", style: theme.text28Red)
    ],));
    list.add(SizedBox(height: 20,));
    list.add(_restaurantsComboBoxInForm());
    list.add(Row(children: [
      Text(strings.get(186), style: theme.text12bold,),  //  "Select Restaurant"
      SizedBox(width: 4,),
      Text("*", style: theme.text28Red)
    ],));
    list.add(SizedBox(height: 20,));
    list.add(IButton3(color: theme.colorPrimary,
        text: strings.get(65),              // Save
        textStyle: theme.text14boldWhite,
        pressButton: _addNewExtrasGroup
    ));
    list.add(SizedBox(height: 150,));
    return list;
  }

  _addExtras(){
    List<Widget> list = [];
    list.add(_titlePath((_editItem) ? "${strings.get(94)} > ${strings.get(199)} > ${strings.get(108)}" :
          "${strings.get(94)} > ${strings.get(199)} > ${strings.get(200)}"));  // "Foods",  // Extras", Edit Add
    list.add(SizedBox(height: 20,));
    if (!_editItem)
      list.add(Text(strings.get(203), style: theme.text16bold, textAlign: TextAlign.center,));  // "Add Extras",
    else
      list.add(Text(strings.get(204), style: theme.text16bold, textAlign: TextAlign.center,));  // "Edit Extras"
    list.add(SizedBox(height: 20,));
    list.add(formEdit(strings.get(113), editControllerName, "", 100)); // Name
    list.add(SizedBox(height: 20,));
    list.add(formEditPrice(strings.get(183), editControllerPrice, "", _numberOfDigits)); // Price -
    list.add(Row(children: [
      Text(strings.get(184), style: theme.text12bold,),  //  "Enter Price",
      SizedBox(width: 4,),
      Text("*", style: theme.text28Red)
    ],));
    list.add(SizedBox(height: 20,));
    list.add(_extrasGroupComboBoxInForm());
    list.add(Row(children: [
      Text(strings.get(205), style: theme.text12bold,),  //   "Select Extras Groups",
      SizedBox(width: 4,),
      Text("*", style: theme.text28Red)
    ],));
    list.add(SizedBox(height: 20,));
    list.add(formEdit(strings.get(169), editControllerDesc, strings.get(170), 250)); // Description - "Enter description",
    list.add(SizedBox(height: 20,));
    list.add(selectImage(windowWidth, _makeImageDialog, theme.colorGrey, Colors.black.withAlpha(150)));               // select image
    list.add(SizedBox(height: 20,));
    list.add(Text(strings.get(173), style: theme.text14, textAlign: TextAlign.start,));  // "Current Image",
    list.add(SizedBox(height: 20,));
    for (var file in _imagesFiles){
      if (file.localFile.isNotEmpty)
        list.add(Container(child: drawImageLocal(file.localFile, windowWidth, false, (String _){}, file.id)));
      if (file.serverFile.isNotEmpty)
        list.add(Container(child: drawImageServer(file.serverFile, windowWidth, false, (String _){}, file.id)));
    }
    // for (var file in _imagePath)
    //   list.add(Container(child: drawImageLocal(file, windowWidth, false)));
    // for (var file in _serverImagePath)
    //   list.add(Container(child: drawImageServer(file, windowWidth, false)));
    list.add(SizedBox(height: 20,));
    list.add(IButton3(color: theme.colorPrimary,
        text: strings.get(65),              // Save
        textStyle: theme.text14boldWhite,
        pressButton: _addNewExtras
    ));
    list.add(SizedBox(height: 150,));
    return list;
  }

  _addNewExtras(){
    if (editControllerName.text.isEmpty)
      return _openDialogError(strings.get(172));  // "The Name field is request",
    if (_extrasGroupValueOnForm == 0)
      return _openDialogError(strings.get(206));  // "The Extras Group field is request",
    if (editControllerPrice.text.isEmpty)
      return _openDialogError(strings.get(194));  // "The Price field is request",
    _waits(true);
    _extrasSave();
  }

  _extrasSave() async {
    for (var file in _imagesFiles)
      if (file.localFile.isNotEmpty)
        file.id = await uploadImage(file.localFile, account.token, (String path, String id) {}, _openDialogError);

    _extrasSave2((_imagesFiles.isNotEmpty) ? _imagesFiles[0] : "");
    // if (_imagePath.isNotEmpty)
    //   uploadImage(_imagePath[0], account.token, (String path, String id) {
    //     _extrasSave2(id);
    //   }, _openDialogError);
    // else
    //   _extrasSave2((_imageId.isNotEmpty) ? _imageId[0] : "");
  }

  _extrasSave2(String image){
    extrasSave(editControllerName.text, _extrasGroupValueOnForm.toString(), editControllerPrice.text,
        editControllerDesc.text, image,
        (_editItem) ? "1" : "0", _editItemId,
        account.token, (List<ImageData> image, List<ExtrasData> extras, String id) {
          _extras = extras;
          _image = image;
          _state = "viewExtrasList";
          _ensureVisibleId = id;
          _waits(false);
          setState(() {});
        }, _openDialogError);
  }

  _nutritionComboBoxInForm(){
    List<DropdownMenuItem> menuItems = [];
    menuItems.add(DropdownMenuItem(
      child: Text(strings.get(189), style: theme.text14,), // No
      value: 0,
    ),);
    for (var item in _nutritionGroup) {
      menuItems.add(DropdownMenuItem(
        child: Text(item.name, style: theme.text14,),
        value: item.id,
      ),);
    }
    return Container(
        width: windowWidth,
        child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
                isExpanded: true,
                value: _nutritionGroupValueOnForm,
                items: menuItems,
                onChanged: (value) {
                  _nutritionGroupValueOnForm = value;
                  setState(() {
                  });
                })
        ));
  }

  _extrasComboBoxInForm(){
    List<DropdownMenuItem> menuItems = [];
    menuItems.add(DropdownMenuItem(
      child: Text(strings.get(189), style: theme.text14,), // No
      value: 0,
    ),);
    for (var item in _extrasGroup) {
      menuItems.add(DropdownMenuItem(
        child: Text(item.name, style: theme.text14,),
        value: item.id,
      ),);
    }
    return Container(
        width: windowWidth,
        child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
                isExpanded: true,
                value: _extrasGroupValueOnForm,
                items: menuItems,
                onChanged: (value) {
                  _extrasGroupValueOnForm = value;
                  setState(() {
                  });
                })
        ));
  }

  _extrasGroupComboBoxInForm(){
    List<DropdownMenuItem> menuItems = [];
    menuItems.add(DropdownMenuItem(
      child: Text(strings.get(189), style: theme.text14,), // No
      value: 0,
    ),);
    for (var item in _extrasGroup) {
      menuItems.add(DropdownMenuItem(
        child: Text(item.name, style: theme.text14,),
        value: item.id,
      ),);
    }
    return Container(
        width: windowWidth,
        child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
                isExpanded: true,
                value: _extrasGroupValueOnForm,
                items: menuItems,
                onChanged: (value) {
                  _extrasGroupValueOnForm = value;
                  setState(() {
                  });
                })
        ));
  }

  _restaurantsComboBoxInForm(){
    List<DropdownMenuItem> menuItems = [];
    menuItems.add(DropdownMenuItem(
      child: Text(strings.get(189), style: theme.text14,), // No
      value: 0,
    ),);
    for (var item in _restaurants) {
      menuItems.add(DropdownMenuItem(
        child: Text(item.name, style: theme.text14,),
        value: item.id,
      ),);
    }
    return Container(
        width: windowWidth,
        child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
                isExpanded: true,
                value: _restaurantValueOnForm,
                items: menuItems,
                onChanged: (value) {
                  _restaurantValueOnForm = value;
                  setState(() {
                  });
                })
        ));
  }

  _categoryComboBoxInForm(){
    List<DropdownMenuItem> menuItems = [];
    menuItems.add(DropdownMenuItem(
      child: Text(strings.get(189), style: theme.text14,), // No
      value: 0,
    ),);
    for (var item in _cat) {
      menuItems.add(DropdownMenuItem(
        child: Text(item.name, style: theme.text14,),
        value: item.id,
      ),);
    }
    return Container(
      width: windowWidth,
      child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton(
              isExpanded: true,
              value: _categoryValueOnForm,
              items: menuItems,
              onChanged: (value) {
                _categoryValueOnForm = value;
                setState(() {
                });
              })
      )
    );
  }

  _addCategory(){
    List<Widget> list = [];
    list.add(_titlePath((_editItem) ? "${strings.get(94)} > ${strings.get(135)} > ${strings.get(108)}" :
              "${strings.get(94)} > ${strings.get(135)} > ${strings.get(200)}"));  // "Foods",  // "Category", Edit Add
    list.add(SizedBox(height: 20,));
    list.add(Text((_editItem) ? strings.get(201) : strings.get(168), style: theme.text16bold, textAlign: TextAlign.center,));  // "Add New Category",
    list.add(SizedBox(height: 20,));
    list.add(formEdit(strings.get(113), editControllerName, strings.get(167), 100)); // Name - "Enter Category name",
    list.add(SizedBox(height: 20,));
    list.add(formEdit(strings.get(169), editControllerDesc, strings.get(170), 100)); // Description - "Enter description",
    list.add(SizedBox(height: 20,));
    list.add(_categoryComboBox2(toInt(_editItemId)));
    list.add(Container(
      width: windowWidth,
      child: Text(strings.get(247), style: theme.text12bold, textAlign: TextAlign.start,),                // Choose Category
    ));
    list.add(SizedBox(height: 20,));
    list.add(selectImage(windowWidth, _makeImageDialog, theme.colorGrey, Colors.black.withAlpha(150)));               // select image
    list.add(SizedBox(height: 20,));
    list.add(Text(strings.get(173), style: theme.text14, textAlign: TextAlign.start,));  // "Current Image",
    list.add(SizedBox(height: 20,));
    for (var file in _imagesFiles){
      if (file.localFile.isNotEmpty)
        list.add(Container(child: drawImageLocal(file.localFile, windowWidth, false, (String _){}, file.id)));
      if (file.serverFile.isNotEmpty)
        list.add(Container(child: drawImageServer(file.serverFile, windowWidth, false, (String _){}, file.id)));
    }
    // for (var file in _imagePath)
    //   list.add(Container(child: drawImageLocal(file, windowWidth, false)));
    // for (var file in _serverImagePath)
    //   list.add(Container(child: drawImageServer(file, windowWidth, false)));
    list.add(SizedBox(height: 20,));
    list.add(checkBox(strings.get(171), _published, (bool value){setState(() {_published = value;});}));                      // "Published item",
    list.add(SizedBox(height: 20,));
    list.add(IButton3(color: theme.colorPrimary,
        text: strings.get(65),              // Save
        textStyle: theme.text14boldWhite,
        pressButton: _addNewCategory
    ));

    list.add(SizedBox(height: 150,));
    return list;
  }

  _addNewExtrasGroup(){
    if (editControllerName.text.isEmpty)
      return _openDialogError(strings.get(172));  // "The Name field is request",
    if (_restaurantValueOnForm == 0)
      return _openDialogError(strings.get(192));  // "The Restaurant field is request",
    _waits(true);
    _extrasGroupSave();
  }

  _addNewFood() async {
    if (editControllerName.text.isEmpty)
      return _openDialogError(strings.get(172));  // "The Name field is request",
    if (editControllerPrice.text.isEmpty)
      return _openDialogError(strings.get(194));  // "The Price field is request",
    if (_restaurantValueOnForm == 0)
      return _openDialogError(strings.get(192));  // "The Restaurant field is request",
    if (_categoryValueOnForm == 0)
      return _openDialogError(strings.get(193));  // "The Category field is request",
    _waits(true);

    for (var file in _imagesFiles)
      if (file.localFile.isNotEmpty)
        file.id = await uploadImage(file.localFile, account.token, (String path, String id) {}, _openDialogError);

    // if (_imagePath.isNotEmpty)
    //   for (var file in _imagePath) {
    //     var ret = await uploadImage(file, account.token, (String path, String id) {}, _openDialogError);
    //     _imageId.add(ret);
    //   }

    _foodSave();
  }

  _addNewCategory() async {
    var name = editControllerName.text;
    if (name.isEmpty)
      return _openDialogError(strings.get(172));  // "The Name field is request",
    _waits(true);
    var desc = editControllerDesc.text;

    for (var file in _imagesFiles)
      if (file.localFile.isNotEmpty)
        file.id = await uploadImage(file.localFile, account.token, (String path, String id) {}, _openDialogError);

    // if (_imagePath.isNotEmpty)
    //   uploadImage(_imagePath[0], account.token, (String path, String id) {
    //     _catSave(name, desc, id);
    //   }, _openDialogError);
    // else
      _catSave(name, desc, (_imagesFiles.isNotEmpty) ? _imagesFiles[0].id : "");
  }

  _catSave(String name, String desc, String imageid){
    categorySave(name, desc, imageid, (_published) ? "1" : "0",
        _categoryValue.toString(),
        (_editItem) ? "1" : "0", _editItemId,
        account.token, (List<ImageData> image, List<CategoriesData> cat, String id) {
          _image = image; _cat = cat;
          _state = "viewCategoryList";
          _ensureVisibleId = id;
          _waits(false);
          setState(() {});
        }, _openDialogError);
  }

  _extrasGroupSave(){
    extrasGroupSave(editControllerName.text, _restaurantValueOnForm.toString(),
        (_editItem) ? "1" : "0", _editItemId,
        account.token, (List<ExtrasGroupData> extrasGroup, String id) {
          _extrasGroup = extrasGroup;
          _state = "viewExtrasGroupList";
          _ensureVisibleId = id;
          _waits(false);
          setState(() {});
        }, _openDialogError);
  }

  _foodSave(){
    var imageid = "";
    var moreimages = "";
    var first = true;
    for (var item in _imagesFiles){
      if (first){
        first = false;
        imageid = item.id;
      }else{
        if (moreimages.isNotEmpty)
          moreimages = "$moreimages,";
        moreimages = "$moreimages${item.id}";
      }
    }

    foodSave(moreimages, editControllerName.text, editControllerDesc.text, imageid, (_published) ? "1" : "0",
        editControllerPrice.text, editControllerDiscountPrice.text, _restaurantValueOnForm.toString(), _categoryValueOnForm.toString(),
        editControllerIngredients.text, _extrasGroupValueOnForm.toString(), _nutritionGroupValueOnForm.toString(),
      (_editItem) ? "1" : "0", _editItemId, _cacheVariants,
      account.token, (List<ImageData> image, List<FoodsData> foods, List<RestaurantData> restaurants,
            List<ExtrasGroupData> extrasGroup, List<NutritionGroupData> nutritionGroup, String id) {
        _image = image;
        _foods = foods;
        _restaurants = restaurants;
        _extrasGroup = extrasGroup;
        _nutritionGroup = nutritionGroup;
        _state = "viewFoodsList";
        _ensureVisibleId = id;
        _waits(false);
        setState(() {});
      }, _openDialogError);
  }

  _makeImageDialog(){
    _dialogBody = Container(
        width: windowWidth,
        child: Column(
          children: [
            Text(strings.get(126), textAlign: TextAlign.center, style: theme.text18boldPrimary,), // "Select image from",
            SizedBox(height: 50,),
            Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: windowWidth/2-25,
                        child: IButton3(
                        color: theme.colorPrimary,
                        text: strings.get(127), // "Camera",
                        textStyle: theme.text14boldWhite,
                        pressButton: (){
                          setState(() {
                            _show = 0;
                          });
                          getImage2(ImageSource.camera);
                        }
                    )),
                    SizedBox(width: 10,),
                Container(
                  width: windowWidth/2-25,
                  child: IButton3(
                        color: theme.colorPrimary,
                        text: strings.get(128), // Gallery
                        textStyle: theme.text14boldWhite,
                        pressButton: (){
                          setState(() {
                            _show = 0;
                          });
                          getImage2(ImageSource.gallery);
                        }
                    )),
                  ],
                )),
          ],
        )
    );
    setState(() {
      _show = 1;
    });
  }

  Future getImage2(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null && pickedFile.path != null) {
      print("Photo file: ${pickedFile.path}");
      if (_state != "addFood" && _state != "editFood")
        _imagesFiles = [];
      _imagesFiles.add(ImageFilesData("", pickedFile.path, ""));
      // _imagePath.add(pickedFile.path);
      setState(() {
      });
    }
  }

  _getCatLength(){
    if (_cat != null){
      if (theme.appTypePre == "multivendor") {
        var length = 0;
        for (var item in _cat)
          if (item.vendor == _vendor)
            length++;
        return length;
      }
      return _cat.length;
    }
    return 0;
  }

  _bodyRoot(){
    List<Widget> list = [];
    list.add(SizedBox(height: 20,));
    // categories
    list.add(oneItem(strings.get(160), "", "${strings.get(162)} ${_getCatLength()}",
        _getRandomImageFromCategories(), windowWidth, "")); // "Categories"  // "Total Count:"
    list.add(SizedBox(height: 5,));
    list.add(buttonsViewAllAndAddNew((){_changeState("viewCategoryList");}, (){_changeState("addCategory");}, windowWidth));
    list.add(SizedBox(height: 20,));
    // foods
    list.add(oneItem(strings.get(34), "", "${strings.get(162)} ${(_foods != null) ? _foods.length : 0}",
        _getRandomImageFromFoods(), windowWidth, "")); // "Products"  // "Total Count:"
    list.add(SizedBox(height: 5,));
    list.add(buttonsViewAllAndAddNew((){_changeState("viewFoodsList");}, (){_changeState("addFood");}, windowWidth));
    list.add(SizedBox(height: 20,));
    if (theme.extras){
      // Extras Group
      list.add(oneItem(strings.get(195), "", "${strings.get(162)} ${(_extrasGroup != null) ? _extrasGroup.length : 0}",
          _getRandomImageFromExtrasGroup(), windowWidth, "")); // "Extras Groups"  // "Total Count:"
      list.add(SizedBox(height: 5,));
      list.add(buttonsViewAllAndAddNew((){_changeState("viewExtrasGroupList");}, (){_changeState("addExtrasGroup");}, windowWidth));
      list.add(SizedBox(height: 20,));
      // Extras
      list.add(oneItem(strings.get(199), "", "${strings.get(162)} ${(_extras != null) ? _extras.length : 0}",
          _getRandomImageFromExtras(), windowWidth, "")); // "Extras"  // "Total Count:"
      list.add(SizedBox(height: 5,));
      list.add(buttonsViewAllAndAddNew((){_changeState("viewExtrasList");}, (){_changeState("addExtras");}, windowWidth));
      list.add(SizedBox(height: 20,));
    }

    // Foods on Home Screen

    list.add(SizedBox(height: 150,));
    return list;
  }

  final _random = new Random();
  int next(int min, int max) => min + _random.nextInt(max - min);

  _getRandomImageFromFoods(){
     if (_foods != null && _foods.isNotEmpty){ // mainn
       var id = 0;
       if (_foods.length != 1)
        id = next(0, _foods.length-1);
       var imageId = _foods[id].imageid;
       for (int i = 0; i < 30; i++) {
         for (var item in _image)
           if (item.id == imageId)
             return "$serverImages${item.filename}";
       }
       return serverImgNoImage;
    }  else
      return serverImgNoImage;
  }

  _getRandomImageFromCategories(){
    if (_cat != null && _cat.isNotEmpty){
      var id = 0;
      if (_cat.length != 1)
        id = next(0, _cat.length-1);
      var imageId = _cat[id].imageid;
      for (int i = 0; i < 30; i++) {
        for (var item in _image)
          if (item.id == imageId)
            return "$serverImages${item.filename}";
      }
      return serverImgNoImage;
    }  else
      return serverImgNoImage;
  }

  _getRandomImageFromExtrasGroup(){
      return serverImgNoImage;
  }

  _getRandomImageFromExtras(){
    if (_extras != null && _extras.isNotEmpty){
      var id = 0;
      if (_extras.length != 1)
        id = next(0, _extras.length-1);
      var imageId = _extras[id].imageid;
      for (int i = 0; i < 30; i++) {
        for (var item in _image)
          if (item.id == imageId)
            return "$serverImages${item.filename}";
      }
      return serverImgNoImage;
    }  else
      return serverImgNoImage;
  }

  _deleteDialog(String id){
    if (demoMode == "true")
      return _openDialogError(strings.get(248)); // "This is demo application. Your can not modify this section.",

    _dialogBody =  Container(
      width: windowWidth,
        child: Column(
          children: [
            Text(strings.get(111), textAlign: TextAlign.center, style: theme.text18boldPrimary,), // "Are you sure?",
            SizedBox(height: 20,),
            Text(strings.get(112), textAlign: TextAlign.center, style: theme.text16,), // "You will not be able to recover this item!"
            SizedBox(height: 50,),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Container(
          width: windowWidth/2-25,
            child: IButton3(
                  color: Colors.red,
                  text: strings.get(109),                     // Yes, delete it!
                  textStyle: theme.text14boldWhite,
                  pressButton: (){
                    setState(() {
                      _show = 0;
                    });
                    _ensureVisibleId = "";
                    if (_state == "viewFoodsList")
                      _deleteFood(id);
                    if (_state == "viewCategoryList")
                      _deleteCategory(id);
                    if (_state == "viewExtrasGroupList")
                      _deleteExtrasGroup(id);
                    if (_state == "viewExtrasList")
                      _deleteExtras(id);
                  }
              )),
              SizedBox(width: 10,),
            Container(
              width: windowWidth/2-25,
              child: IButton3(
                  color: theme.colorPrimary,
                  text: strings.get(110),                 // No, cancel plx!
                  textStyle: theme.text14boldWhite,
                  pressButton: (){
                    setState(() {
                      _show = 0;
                    });
                  }
              )),
            ],
          )),

          ],
        )
    );
    setState(() {
      _show = 1;
    });
  }

  bool _searchPublished = true;
  bool _searchHidden = true;
  var _categoryValue = 0;
  var _restaurantValue = 0;
  var _extrasGroupValue = 0;

  _categoryComboBox2(int id){
    var found = false;
    List<DropdownMenuItem> menuItems = [];
    menuItems.add(DropdownMenuItem(
      child: Text(strings.get(189), style: theme.text14,), // No
      value: 0,
    ),);
    for (var item in _cat) {
      if (item.id != id) {
        menuItems.add(DropdownMenuItem(
          child: Text(item.name, style: theme.text14,),
          value: item.id,
        ),);
      }
      if (item.id == _categoryValue)
        found = true;
    }
    if (!found)
      _categoryValue = 0;
    return Container(
        width: windowWidth,
        child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
                isExpanded: true,
                value: _categoryValue,
                items: menuItems,
                onChanged: (value) {
                  _categoryValue = value;
                  setState(() {
                  });
                })
        ));
  }

  _categoryComboBox(){
    List<DropdownMenuItem> menuItems = [];
    menuItems.add(DropdownMenuItem(
      child: Text(strings.get(180), style: theme.text14,), // All
      value: 0,
    ),);
    if (_cat != null)
      for (var item in _cat) {
        menuItems.add(DropdownMenuItem(
          child: Text(item.name, style: theme.text14,),
          value: item.id,
        ),);
      }
    return Container(
        width: windowWidth,
        child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
                isExpanded: true,
                value: _categoryValue,
                items: menuItems,
                onChanged: (value) {
                  _categoryValue = value;
                  setState(() {
                  });
                })
        ));
  }

  _restaurantsComboBox(){
    List<DropdownMenuItem> menuItems = [];
    menuItems.add(DropdownMenuItem(
      child: Text(strings.get(180), style: theme.text14,), // All
      value: 0,
    ),);
    for (var item in _restaurants) {
      menuItems.add(DropdownMenuItem(
        child: Text(item.name, style: theme.text14,),
        value: item.id,
      ),);
    }
    return Container(
        width: windowWidth,
        child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
                isExpanded: true,
                value: _restaurantValue,
                items: menuItems,
                onChanged: (value) {
                  _restaurantValue = value;
                  //_dialogBody = _getBodySearchDialog();
                  setState(() {
                  });
                })
        ));
  }

  _extrasGroupComboBox(){
    List<DropdownMenuItem> menuItems = [];
    menuItems.add(DropdownMenuItem(
      child: Text(strings.get(180), style: theme.text14,), // All
      value: 0,
    ),);
    for (var item in _extrasGroup) {
      menuItems.add(DropdownMenuItem(
        child: Text(item.name, style: theme.text14,),
        value: item.id,
      ),);
    }
    return Container(
        width: windowWidth,
        child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
                isExpanded: true,
                value: _extrasGroupValue,
                items: menuItems,
                onChanged: (value) {
                  _extrasGroupValue = value;
                  setState(() {
                  });
                })
        ));
  }


}

