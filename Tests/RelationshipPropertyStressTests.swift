/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import XCTest
@testable import Graph

class RelationshipPropertyStressTests: XCTestCase, GraphRelationshipDelegate {
    var saveException: XCTestExpectation?
    
    var relationshipInsertException: XCTestExpectation?
    var relationshipDeleteException: XCTestExpectation?
    
    var propertyInsertExpception: XCTestExpectation?
    var propertyUpdateExpception: XCTestExpectation?
    var propertyDeleteExpception: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPropertyStress() {
        saveException = expectation(description: "[RelationshipPropertyStressTests Error: Graph save test failed.]")
        relationshipInsertException = expectation(description: "[RelationshipPropertyStressTests Error: Relationship insert test failed.]")
        
        let graph = Graph()
        graph.delegate = self
        graph.watchForRelationship(types: ["T"])
        
        let relationship = Relationship(type: "T")
        
        graph.async { [weak self] (success: Bool, error: Error?) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveException?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        for i in 0..<100 {
            let property = "P\(i)"
            var value = i
            
            graph.watchForRelationship(properties: [property])
            
            relationship[property] = value
            
            XCTAssertEqual(value, relationship[property] as? Int)
            
            saveException = expectation(description: "[RelationshipPropertyStressTests Error: Graph save test failed.]")
            propertyInsertExpception = expectation(description: "[RelationshipPropertyStressTests Error: Property insert test failed.]")
            
            graph.async { [weak self] (success: Bool, error: Error?) in
                XCTAssertTrue(success)
                XCTAssertNil(error)
                self?.saveException?.fulfill()
            }
            
            waitForExpectations(timeout: 5, handler: nil)
            
            value += 1
            relationship[property] = value
            
            XCTAssertEqual(value, relationship[property] as? Int)
            
            saveException = expectation(description: "[RelationshipPropertyStressTests Error: Graph save test failed.]")
            propertyUpdateExpception = expectation(description: "[RelationshipPropertyStressTests Error: Property update test failed.]")
            
            graph.async { [weak self] (success: Bool, error: Error?) in
                XCTAssertTrue(success)
                XCTAssertNil(error)
                self?.saveException?.fulfill()
            }
            
            waitForExpectations(timeout: 5, handler: nil)
            
            relationship[property] = nil
            
            XCTAssertNil(relationship[property])
            
            saveException = expectation(description: "[RelationshipPropertyStressTests Error: Graph save test failed.]")
            propertyDeleteExpception = expectation(description: "[RelationshipPropertyStressTests Error: Property delete test failed.]")
            
            graph.async { [weak self] (success: Bool, error: Error?) in
                self?.saveException?.fulfill()
                XCTAssertTrue(success)
                XCTAssertNil(error)
            }
            
            waitForExpectations(timeout: 5, handler: nil)
        }
        
        saveException = expectation(description: "[RelationshipPropertyStressTests Error: Graph save test failed.]")
        relationshipDeleteException = expectation(description: "[RelationshipPropertyStressTests Error: Relationship delete test failed.]")
        
        relationship.delete()
        
        graph.async { [weak self] (success: Bool, error: Error?) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveException?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func graph(graph: Graph, inserted relationship: Relationship, cloud: Bool) {
        XCTAssertTrue("T" == relationship.type)
        XCTAssertTrue(0 < relationship.id.characters.count)
        XCTAssertEqual(0, relationship.properties.count)
        
        relationshipInsertException?.fulfill()
    }
    
    func graph(graph: Graph, deleted relationship: Relationship, cloud: Bool) {
        XCTAssertTrue("T" == relationship.type)
        XCTAssertTrue(0 < relationship.id.characters.count)
        XCTAssertEqual(0, relationship.properties.count)
        
        relationshipDeleteException?.fulfill()
    }
    
    func graph(graph: Graph, relationship: Relationship, added property: String, with value: AnyObject, cloud: Bool) {
        XCTAssertTrue("T" == relationship.type)
        XCTAssertTrue(0 < relationship.id.characters.count)
        
        propertyInsertExpception?.fulfill()
    }
    
    func graph(graph: Graph, relationship: Relationship, updated property: String, with value: AnyObject, cloud: Bool) {
        XCTAssertTrue("T" == relationship.type)
        XCTAssertTrue(0 < relationship.id.characters.count)
        
        propertyUpdateExpception?.fulfill()
    }
    
    func graph(graph: Graph, relationship: Relationship, removed property: String, with value: AnyObject, cloud: Bool) {
        XCTAssertTrue("T" == relationship.type)
        XCTAssertTrue(0 < relationship.id.characters.count)
        
        propertyDeleteExpception?.fulfill()
    }
}
