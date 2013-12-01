module bullet.bindings.classes;

import bullet.bindings.bindings;

mixin template classBasic(string _cppName)
{
	mixin bindingData;

	mixin className!_cppName;
	mixin classSize;
	mixin classPtr;
	mixin refCounting;
	mixin constructorCopy;
	mixin constructorObject;
	mixin destructor;
}

mixin template className(string _cppName)
{
	enum string cppName = _cppName;
}

mixin template classSize()
{
	// by not making _this a static array,
	// the C pointer returned by cppNew can be sliced and retained:
	// _this = (cast(ubyte*)(cppNew(args)))[0..cppSize!(cppName)]
	// iow. C pointer == _this.ptr
	ubyte[] _this;
}

mixin template classPtr()
{
	// get the C pointer
	typeof(this)* ptr() { return cast(typeof(this)*)_this.ptr; }
}

// mixin super class
// child uses _super._this, so do not mixin classPtr for child class
mixin template classSuper(Super)
{
	Super _super;
	alias _super this;
}

// Count references when struct is constructed, destructed or copied
// Not thread safe?
mixin template refCounting()
{
	uint _references = 0;
}

// Copy constructor
// Increases reference count
mixin template constructorCopy()
{
	this(this)
	{
		_references++;
	}
}

mixin template constructorObject()
{
	// construct obj from returned c++ obj
	this(typeof(this) obj_In)
	{
		// only do this for c++ constructed obj (not D objects nor c++ returned obj*)
		assert(obj_In._references == 0);
		
		// .dup obj as ubyte array
		// pointer is not a c++ pointer, cppNew/cppDelete are not involved/needed
		_this = (cast(ubyte*)&obj_In)[0..cppSize!cppName].dup;

		_references = 2; // set refs to 2, so on ~this it becomes 1, and thus cppDelete is never called
	}
}

mixin template classParent(string _cppName)
{
	mixin classBasic!_cppName;
}

mixin template classChild(string _cppName, Super)
{
	mixin bindingData;

	mixin className!_cppName;
	mixin classSuper!Super;
}
