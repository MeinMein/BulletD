module main;

import std.stdio;
import std.conv;
import core.memory;

import bullet.all;

void main()
{
	bool loop = true;

	while(loop)
	{
		if(deb1)writeln(`========================================loop`);
		
		helloWorld();
		
		//GC.collect();
		//GC.minimize();
		//loop = false;
	}

}
bool deb1;// = true;
bool deb2;// = true;

string btScope(string name)
{
	return "scope(exit) " ~ name ~ ".cppDelete();";
}

void helloWorld()
{

//init

	if(deb1)writeln(`broadphase`);
	auto broadphase = btDbvtBroadphase.cppNew();
mixin(btScope(broadphase.stringof));
	if(deb2)writeln(broadphase);

	if(deb1)writeln(`collisionConfiguration`);
	auto collisionConfiguration = btDefaultCollisionConfiguration.cppNew();
mixin(btScope(collisionConfiguration.stringof));
	if(deb2)writeln(collisionConfiguration);

	if(deb1)writeln(`dispatcher`);
	auto dispatcher = btCollisionDispatcher.cppNew(cast(btCollisionConfiguration*)collisionConfiguration);
mixin(btScope(dispatcher.stringof));
	if(deb2)writeln(dispatcher);

	if(deb1)writeln(`solver`);
	auto solver = btSequentialImpulseConstraintSolver.cppNew();
mixin(btScope(solver.stringof));
	if(deb2)writeln(solver);

	if(deb1)writeln(`dynamicsWorld`);
	auto dynamicsWorld = btDiscreteDynamicsWorld.cppNew(cast(btDispatcher*)dispatcher, cast(btBroadphaseInterface*)broadphase, cast(btConstraintSolver*)solver, cast(btCollisionConfiguration*)collisionConfiguration);
mixin(btScope(dynamicsWorld.stringof));
	if(deb2)writeln(dynamicsWorld);

	if(deb1)writeln(dynamicsWorld.getGravity().getY()); // returns an object, no btScope needed
	auto gravity = btVector3.cppNew(0, -10, 0);
mixin(btScope(gravity.stringof));
	if(deb1)dynamicsWorld.setGravity(gravity);
	if(deb1)writeln(dynamicsWorld.getGravity().getY());

	if(deb1)writeln(`groundShape`);
	auto vec3Ground = btVector3.cppNew(0, 1, 0);
mixin(btScope(vec3Ground.stringof));
	auto groundShape = btStaticPlaneShape.cppNew(vec3Ground, 1);
mixin(btScope(groundShape.stringof));
	if(deb2)writeln(groundShape);
	if(deb1)writeln(groundShape.getPlaneConstant());

	if(deb1)writeln(`fallShape`);
	auto fallShape = btSphereShape.cppNew(1);
mixin(btScope(fallShape.stringof));
	if(deb2)writeln(fallShape);
	if(deb1)writeln(fallShape.getRadius());

	if(deb1)writeln(`groundMotionState`);
	auto quatTrans = btQuaternion.cppNew(0, 0, 0, 1);
mixin(btScope(quatTrans.stringof));
	auto vec3Trans = btVector3.cppNew(0, -1, 0);
mixin(btScope(vec3Trans.stringof));
	auto transform = btTransform.cppNew(quatTrans, vec3Trans);
mixin(btScope(transform.stringof));
	auto groundMotionState = btDefaultMotionState.cppNew(transform);
//mixin(btScope(groundMotionState.stringof));// removed in cleanup
	if(deb2)writeln(groundMotionState);
	if(deb1)groundMotionState.getWorldTransform(transform);// ref local var, no btScope needed
	if(deb1)writeln(transform.getOrigin().getY());// returns an object, no btScope needed

	if(deb1)writeln(`groundRigidBodyCI`);
	auto vec3RB = btVector3.cppNew(0, 0, 0);
mixin(btScope(vec3RB.stringof));
	auto groundRigidBodyCI = btRigidBodyConstructionInfo.cppNew(0, cast(btMotionState*)groundMotionState, cast(btCollisionShape*)groundShape, vec3RB);
mixin(btScope(groundRigidBodyCI.stringof));
	if(deb2)writeln(groundRigidBodyCI);
	
	if(deb1)writeln(`groundRigidBody`);
	auto groundRigidBody = btRigidBody.cppNew(groundRigidBodyCI);
mixin(btScope(groundRigidBody.stringof));
	if(deb2)writeln(groundRigidBody);

	dynamicsWorld.addRigidBody(cast(btRigidBody*)groundRigidBody);

	if(deb1)writeln(`fallMotionState`);
	auto quatFall = btQuaternion.cppNew(0, 0, 0, 1);
mixin(btScope(quatFall.stringof));
	auto vec3Fall = btVector3.cppNew(0, 50, 0);
mixin(btScope(vec3Fall.stringof));
	auto transFall = btTransform.cppNew(quatFall, vec3Fall);
mixin(btScope(transFall.stringof));
	auto fallMotionState = btDefaultMotionState.cppNew(transFall);
//mixin(btScope(fallMotionState.stringof));// removed in cleanup
	if(deb2)writeln(fallMotionState);

	btScalar mass = 1;
	auto fallInertia = btVector3.cppNew(0, 0, 0);
mixin(btScope(fallInertia.stringof));
	fallShape.calculateLocalInertia(mass, fallInertia);

	if(deb1)writeln(`fallRigidBodyCI`);
	auto fallRigidBodyCI = btRigidBodyConstructionInfo.cppNew(mass, cast(btMotionState*)fallMotionState, cast(btCollisionShape*)fallShape, fallInertia);
mixin(btScope(fallRigidBodyCI.stringof));
	if(deb2)writeln(fallRigidBodyCI);
	if(deb1)writeln(`fallRigidBody`);
	auto fallRigidBody = btRigidBody.cppNew(fallRigidBodyCI);
mixin(btScope(fallRigidBody.stringof));
	if(deb2)writeln(fallRigidBody);

	dynamicsWorld.addRigidBody(fallRigidBody);

// loop

	for(int i = 0; i < 300; i++)
	{
		if(deb2)writeln("loop ", i);
		dynamicsWorld.stepSimulation(1f/60f, 10);

		auto trans = btTransform.cppNew();
		mixin(btScope(trans.stringof));

		auto msP = fallRigidBody.getMotionState(); // returns obj*, but that obj* is already btScoped above^
		msP.getWorldTransform(trans);// ref local var, no btScope needed

		if(deb1)writeln("sphere height: ", trans.getOrigin().getY());// returns an object, no btScope needed
	}

// cleanup

	// (most are taken care of via mixin(btScope(... .stringof));)

	dynamicsWorld.removeRigidBody(fallRigidBody);
	auto delMS1 = fallRigidBody.getMotionState();
mixin(btScope(delMS1.stringof));

	dynamicsWorld.removeRigidBody(groundRigidBody);
	auto delMS2 = groundRigidBody.getMotionState();
mixin(btScope(delMS2.stringof));
}
