-- IP-XACT SQLite Schema

-- Metadata table - stores component information and metadata
CREATE TABLE metadata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    vendor TEXT NOT NULL,           -- <spirit:vendor> or <ipxact:vendor>
    library TEXT NOT NULL,          -- <spirit:library> or <ipxact:library>
    name TEXT NOT NULL,             -- <spirit:name> or <ipxact:name>
    version TEXT NOT NULL,          -- <spirit:version> or <ipxact:version>
    description TEXT,               -- <spirit:description> or <ipxact:description>
    namespace TEXT NOT NULL,        -- XML namespace (spirit or ipxact)
    schemaVersion TEXT NOT NULL,    -- <spirit:schemaVersion> or <ipxact:schemaVersion>
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    author TEXT,                    -- <kactus2:author>
    toolVersion TEXT,              -- <kactus2:version>
    productHierarchy TEXT,         -- <kactus2:kts_productHier>
    implementationType TEXT,       -- <kactus2:kts_implementation>
    firmness TEXT,                -- <kactus2:kts_firmness>
    generatorTool TEXT,           -- <spirit:generatorTool> or <ipxact:generatorTool>
    generatorVersion TEXT,        -- <spirit:generatorVersion> or <ipxact:generatorVersion>
    lastModified TIMESTAMP,       -- Last modification timestamp
    sourceFile TEXT,              -- Original XML file path
    checksum TEXT,                -- XML file checksum for change detection
    displayName TEXT,             -- <spirit:displayName> or <ipxact:displayName>
    typeIdentifier TEXT,          -- <spirit:typeIdentifier> or <ipxact:typeIdentifier>
    longDescription TEXT,         -- <spirit:longDescription> or <ipxact:longDescription>
    hierarchyRef TEXT,            -- <spirit:hierarchyRef> or <ipxact:hierarchyRef>
    viewRef TEXT,                 -- <spirit:viewRef> or <ipxact:viewRef>
    swModel TEXT,                 -- <spirit:swModel> or <ipxact:swModel>
    hwModel TEXT,                 -- <spirit:hwModel> or <ipxact:hwModel>
    fileSetRef TEXT,              -- <spirit:fileSetRef> or <ipxact:fileSetRef>
    designConfigRef TEXT,         -- <spirit:designConfigRef> or <ipxact:designConfigRef>
    componentGeneratorRef TEXT,   -- <spirit:componentGeneratorRef> or <ipxact:componentGeneratorRef>
    whiteboxType TEXT,           -- <spirit:whiteboxType> or <ipxact:whiteboxType>
    buildCommand TEXT,           -- <spirit:buildCommand> or <ipxact:buildCommand>
    UNIQUE(vendor, library, name, version),
    CHECK (namespace IN ('spirit', 'ipxact'))
);

-- Memory Maps table - stores memory map information
CREATE TABLE memoryMaps (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    metadata_id INTEGER NOT NULL,    -- Foreign key to metadata table
    name TEXT NOT NULL,             -- <spirit:name> or <ipxact:name>
    description TEXT,               -- <spirit:description> or <ipxact:description>
    addressUnitBits INTEGER,        -- <spirit:addressUnitBits> or <ipxact:addressUnitBits>
    usage TEXT,                     -- <spirit:usage> or <ipxact:usage>
    displayName TEXT,               -- <spirit:displayName> or <ipxact:displayName>
    bigEndian BOOLEAN,              -- <spirit:bigEndian> or <ipxact:bigEndian>
    typeIdentifier TEXT,            -- <spirit:typeIdentifier> or <ipxact:typeIdentifier>
    longDescription TEXT,           -- <spirit:longDescription> or <ipxact:longDescription>
    memoryMapRef TEXT,              -- <spirit:memoryMapRef> or <ipxact:memoryMapRef>
    systemGroup TEXT,               -- <spirit:systemGroup> or <ipxact:systemGroup>
    shared BOOLEAN DEFAULT 0,       -- <spirit:shared> or <ipxact:shared>
    bankAlignment TEXT,             -- <spirit:bankAlignment> or <ipxact:bankAlignment>
    remapAddress TEXT,              -- <spirit:remapAddress> or <ipxact:remapAddress>
    remapState TEXT,                -- <spirit:remapState> or <ipxact:remapState>
    remapPort TEXT,                 -- <spirit:remapPort> or <ipxact:remapPort>
    addressSpaceRef TEXT,           -- <spirit:addressSpaceRef> or <ipxact:addressSpaceRef>
    componentRef TEXT,              -- <spirit:componentRef> or <ipxact:componentRef>
    configurableElement TEXT,       -- <spirit:configurableElement> or <ipxact:configurableElement>
    monitorInterface TEXT,          -- <spirit:monitorInterface> or <ipxact:monitorInterface>
    bridgeInterface TEXT,           -- <spirit:bridgeInterface> or <ipxact:bridgeInterface>
    FOREIGN KEY (metadata_id) REFERENCES metadata(id) ON DELETE CASCADE,
    UNIQUE(metadata_id, name)
);

-- Address Blocks table - stores address block information
CREATE TABLE addressBlocks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    memoryMap_id INTEGER NOT NULL,
    name TEXT NOT NULL,             -- <spirit:name> or <ipxact:name>
    description TEXT,               -- <spirit:description> or <ipxact:description>
    baseAddress TEXT NOT NULL,      -- <spirit:baseAddress> or <ipxact:baseAddress>
    range TEXT NOT NULL,            -- <spirit:range> or <ipxact:range>
    width INTEGER NOT NULL,         -- <spirit:width> or <ipxact:width>
    access TEXT,                    -- <spirit:access> or <ipxact:access>
    usage TEXT,                     -- <spirit:usage> or <ipxact:usage>
    volatile BOOLEAN DEFAULT 0,     -- <spirit:volatile> or <ipxact:volatile>
    isPresent TEXT,                -- <spirit:isPresent> or <ipxact:isPresent>
    protection TEXT,               -- <spirit:protection> or <ipxact:protection>
    execPermission BOOLEAN,        -- <spirit:execPermission> or <ipxact:execPermission>
    bridgeType TEXT,               -- <spirit:bridgeType> or <ipxact:bridgeType>
    longDescription TEXT,          -- <spirit:longDescription> or <ipxact:longDescription>
    usageCount INTEGER,            -- <spirit:usageCount> or <ipxact:usageCount>
    physicalName TEXT,             -- <spirit:physicalName> or <ipxact:physicalName>
    cellStrength TEXT,             -- <spirit:cellStrength> or <ipxact:cellStrength>
    cellFunction TEXT,             -- <spirit:cellFunction> or <ipxact:cellFunction>
    priority INTEGER,              -- <spirit:priority> or <ipxact:priority>
    alignment TEXT,                -- <spirit:alignment> or <ipxact:alignment>
    hwModel TEXT,                  -- <spirit:hwModel> or <ipxact:hwModel>
    implementation TEXT,           -- <spirit:implementation> or <ipxact:implementation>
    accessHandleType TEXT,         -- <spirit:accessHandleType> or <ipxact:accessHandleType>
    FOREIGN KEY (memoryMap_id) REFERENCES memoryMaps(id) ON DELETE CASCADE,
    UNIQUE(memoryMap_id, name),
    CHECK (access IN ('read-only', 'write-only', 'read-write', 'writeOnce', 'read-writeOnce')),
    CHECK (usage IN ('register', 'memory'))
);

-- Registers table - stores register information
CREATE TABLE registers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    addressBlock_id INTEGER NOT NULL,
    name TEXT NOT NULL,             -- <spirit:name> or <ipxact:name>
    description TEXT,               -- <spirit:description> or <ipxact:description>
    displayName TEXT,               -- <spirit:displayName> or <ipxact:displayName>
    addressOffset TEXT NOT NULL,    -- <spirit:addressOffset> or <ipxact:addressOffset>
    size INTEGER NOT NULL,          -- <spirit:size> or <ipxact:size>
    access TEXT,                    -- <spirit:access> or <ipxact:access>
    volatile BOOLEAN DEFAULT 0,     -- <spirit:volatile> or <ipxact:volatile>
    resetValue TEXT,               -- <spirit:reset/spirit:value> or <ipxact:reset/ipxact:value>
    resetMask TEXT,                -- <spirit:reset/spirit:mask> or <ipxact:reset/ipxact:mask>
    resetTrigger TEXT,             -- <spirit:reset/spirit:trigger> or <ipxact:reset/ipxact:trigger>
    resetPolarity TEXT,            -- <spirit:reset/spirit:polarity> or <ipxact:reset/ipxact:polarity>
    resetSynchronization TEXT,     -- <spirit:reset/spirit:synchronization> or <ipxact:reset/ipxact:synchronization>
    resetDomain TEXT,              -- <spirit:reset/spirit:domain> or <ipxact:reset/ipxact:domain>
    resetDependency TEXT,          -- <spirit:reset/spirit:dependency> or <ipxact:reset/ipxact:dependency>
    resetSequence TEXT,            -- <spirit:reset/spirit:sequence> or <ipxact:reset/ipxact:sequence>
    dim INTEGER DEFAULT 1,         -- <spirit:dim> or <ipxact:dim>
    dimIncrement TEXT,            -- <spirit:dimIncrement> or <ipxact:dimIncrement>
    isPresent TEXT,               -- <spirit:isPresent> or <ipxact:isPresent>
    alternateRegisters TEXT,       -- <spirit:alternateRegisters> or <ipxact:alternateRegisters>
    modifiedWriteValue TEXT,      -- <spirit:modifiedWriteValue> or <ipxact:modifiedWriteValue>
    readAction TEXT,              -- <spirit:readAction> or <ipxact:readAction>
    testConstraint TEXT,          -- <spirit:testConstraint> or <ipxact:testConstraint>
    typeIdentifier TEXT,          -- <spirit:typeIdentifier> or <ipxact:typeIdentifier>
    bridgeType TEXT,              -- <spirit:bridgeType> or <ipxact:bridgeType>
    longDescription TEXT,         -- <spirit:longDescription> or <ipxact:longDescription>
    groupName TEXT,               -- <spirit:group> or <ipxact:group>
    displayGroup TEXT,            -- <spirit:displayGroup> or <ipxact:displayGroup>
    alternateGroups TEXT,         -- <spirit:alternateGroups> or <ipxact:alternateGroups>
    dependency TEXT,              -- <spirit:dependency> or <ipxact:dependency>
    defaultValue TEXT,            -- <spirit:defaultValue> or <ipxact:defaultValue>
    physicalName TEXT,            -- <spirit:physicalName> or <ipxact:physicalName>
    writeAsRead BOOLEAN DEFAULT 0, -- <spirit:writeAsRead> or <ipxact:writeAsRead>
    singleShot BOOLEAN DEFAULT 0,  -- <spirit:singleShot> or <ipxact:singleShot>
    customGroupName TEXT,          -- <spirit:customGroupName> or <ipxact:customGroupName>
    dataType TEXT,                -- <spirit:dataType> or <ipxact:dataType>
    regFileRef TEXT,              -- <spirit:regFileRef> or <ipxact:regFileRef>
    registerRef TEXT,             -- <spirit:registerRef> or <ipxact:registerRef>
    accessCondition TEXT,         -- <spirit:accessCondition> or <ipxact:accessCondition>
    configGroups TEXT,            -- <spirit:configGroups> or <ipxact:configGroups>
    nameGroup TEXT,               -- <spirit:nameGroup> or <ipxact:nameGroup>
    generateFile TEXT,            -- <spirit:generateFile> or <ipxact:generateFile>
    generatorRef TEXT,            -- <spirit:generatorRef> or <ipxact:generatorRef>
    linkerCommandFile TEXT,       -- <spirit:linkerCommandFile> or <ipxact:linkerCommandFile>
    isSystemFile BOOLEAN DEFAULT 0, -- <spirit:isSystemFile> or <ipxact:isSystemFile>
    isIncludeFile BOOLEAN DEFAULT 0, -- <spirit:isIncludeFile> or <ipxact:isIncludeFile>
    moduleName TEXT,              -- <spirit:moduleName> or <ipxact:moduleName>
    moduleParameters TEXT,        -- <spirit:moduleParameters> or <ipxact:moduleParameters>
    functionName TEXT,            -- <spirit:functionName> or <ipxact:functionName>
    functionArguments TEXT,       -- <spirit:functionArguments> or <ipxact:functionArguments>
    monitorType TEXT,             -- <spirit:monitorType> or <ipxact:monitorType>
    monitorConfig TEXT,           -- <spirit:monitorConfig> or <ipxact:monitorConfig>
    designComponent TEXT,         -- <spirit:designComponent> or <ipxact:designComponent>
    abstractorGenerator TEXT,     -- <spirit:abstractorGenerator> or <ipxact:abstractorGenerator>
    generatorChain TEXT,          -- <spirit:generatorChain> or <ipxact:generatorChain>
    -- UVM-specific columns for SystemVerilog compatibility
    rand BOOLEAN DEFAULT 0,       -- UVM random field flag
    FOREIGN KEY (addressBlock_id) REFERENCES addressBlocks(id) ON DELETE CASCADE,
    CHECK (access IN ('read-only', 'write-only', 'read-write', 'writeOnce', 'read-writeOnce')),
    CHECK (dataType IN ('string', 'integer', 'boolean', 'float', 'hex', 'binary')),
    CHECK (monitorType IN ('status', 'control', 'debug', 'performance', 'error')),
    CHECK (resetPolarity IN ('active-high', 'active-low')),
    CHECK (resetSynchronization IN ('sync', 'async')),
    CHECK (size > 0),
    CHECK (dim > 0)
);

-- Fields table - stores register field information
CREATE TABLE fields (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    register_id INTEGER NOT NULL,
    name TEXT NOT NULL,             -- <spirit:name> or <ipxact:name>
    description TEXT,               -- <spirit:description> or <ipxact:description>
    displayName TEXT,               -- <spirit:displayName> or <ipxact:displayName>
    bitOffset INTEGER,             -- <spirit:bitOffset> or <ipxact:bitOffset>
    bitWidth INTEGER,              -- <spirit:bitWidth> or <ipxact:bitWidth>
    access TEXT,                    -- <spirit:access> or <ipxact:access>
    resetValue TEXT,               -- <spirit:reset/spirit:value> or <ipxact:reset/ipxact:value>
    resetTypeRef TEXT,             -- <spirit:resetTypeRef> or <ipxact:resetTypeRef>
    resetTrigger TEXT,             -- <spirit:reset/spirit:trigger> or <ipxact:reset/ipxact:trigger>
    resetPolarity TEXT,            -- <spirit:reset/spirit:polarity> or <ipxact:reset/ipxact:polarity>
    resetSynchronization TEXT,     -- <spirit:reset/spirit:synchronization> or <ipxact:reset/ipxact:synchronization>
    resetDomain TEXT,              -- <spirit:reset/spirit:domain> or <ipxact:reset/ipxact:domain>
    resetDependency TEXT,          -- <spirit:reset/spirit:dependency> or <ipxact:reset/ipxact:dependency>
    resetSequence TEXT,            -- <spirit:reset/spirit:sequence> or <ipxact:reset/ipxact:sequence>
    resetMask TEXT,                -- <spirit:reset/spirit:mask> or <ipxact:reset/ipxact:mask>
    isVolatile BOOLEAN DEFAULT 0,  -- <spirit:volatile> or <ipxact:volatile>
    isReserved BOOLEAN DEFAULT 0,  -- <spirit:reserved> or <ipxact:reserved>
    modifiedWriteValue TEXT,       -- <spirit:modifiedWriteValue> or <ipxact:modifiedWriteValue>
    readAction TEXT,               -- <spirit:readAction> or <ipxact:readAction>
    writeValueConstraint TEXT,     -- <spirit:writeValueConstraint> or <ipxact:writeValueConstraint>
    testable TEXT,                 -- <spirit:testable> or <ipxact:testable>
    isPresent TEXT,                -- <spirit:isPresent> or <ipxact:isPresent>
    dependence TEXT,               -- <spirit:dependence> or <ipxact:dependence>
    typeIdentifier TEXT,           -- <spirit:typeIdentifier> or <ipxact:typeIdentifier>
    enumValuesRef TEXT,            -- <spirit:enumValuesRef> or <ipxact:enumValuesRef>
    longDescription TEXT,          -- <spirit:longDescription> or <ipxact:longDescription>
    groupName TEXT,                -- <spirit:group> or <ipxact:group>
    displayGroup TEXT,             -- <spirit:displayGroup> or <ipxact:displayGroup>
    alternateGroups TEXT,          -- <spirit:alternateGroups> or <ipxact:alternateGroups>
    usage TEXT,                    -- <spirit:usage> or <ipxact:usage>
    enumName TEXT,                 -- <spirit:enumeratedValue/spirit:name> or <ipxact:enumeratedValue/ipxact:name>
    enumValue TEXT,                -- <spirit:enumeratedValue/spirit:value> or <ipxact:enumeratedValue/ipxact:value>
    enumDisplayName TEXT,          -- <spirit:enumeratedValue/spirit:displayName> or <ipxact:enumeratedValue/ipxact:displayName>
    -- UVM-specific columns for SystemVerilog compatibility
    rand BOOLEAN DEFAULT 0,        -- UVM random field flag
    mirror INTEGER DEFAULT 0,      -- UVM mirror field flag
    volatile BOOLEAN DEFAULT 0,    -- UVM volatile field flag (alias for isVolatile)
    FOREIGN KEY (register_id) REFERENCES registers(id) ON DELETE CASCADE,
    CHECK (access IN ('read-only', 'write-only', 'read-write', 'writeOnce', 'read-writeOnce')),
    CHECK (isVolatile IN (0, 1)),
    CHECK (isReserved IN (0, 1))
);

-- Bus Interfaces table - stores bus interface information
CREATE TABLE busInterfaces (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    metadata_id INTEGER NOT NULL,    -- Foreign key to metadata table
    name TEXT NOT NULL,             -- <spirit:name> or <ipxact:name>
    busType TEXT NOT NULL,          -- <spirit:busType> or <ipxact:busType>
    abstractionType TEXT,           -- <spirit:abstractionType> or <ipxact:abstractionType>
    interfaceMode TEXT,             -- <spirit:interfaceMode> or <ipxact:interfaceMode>
    displayName TEXT,               -- <spirit:displayName> or <ipxact:displayName>
    isPresent TEXT,                -- <spirit:isPresent> or <ipxact:isPresent>
    initiative TEXT,               -- <spirit:initiative> or <ipxact:initiative>
    endianness TEXT,               -- <spirit:endianness> or <ipxact:endianness>
    timingConstraints TEXT,        -- <spirit:timingConstraints> or <ipxact:timingConstraints>
    powerDomain TEXT,              -- <spirit:powerDomain> or <ipxact:powerDomain>
    longDescription TEXT,          -- <spirit:longDescription> or <ipxact:longDescription>
    connectionRequired BOOLEAN DEFAULT 1, -- <spirit:connectionRequired> or <ipxact:connectionRequired>
    busWidth INTEGER,              -- <spirit:busWidth> or <ipxact:busWidth>
    masterRef TEXT,                -- <spirit:masterRef> or <ipxact:masterRef>
    slaveRef TEXT,                 -- <spirit:slaveRef> or <ipxact:slaveRef>
    systemRef TEXT,                -- <spirit:systemRef> or <ipxact:systemRef>
    portAccessType TEXT,           -- <spirit:portAccessType> or <ipxact:portAccessType>
    portAccessHandle TEXT,         -- <spirit:portAccessHandle> or <ipxact:portAccessHandle>
    driverType TEXT,               -- <spirit:driverType> or <ipxact:driverType>
    frequencyHz INTEGER,           -- <spirit:frequencyHz> or <ipxact:frequencyHz>
    onMaster TEXT,                 -- <spirit:onMaster> or <ipxact:onMaster>
    onSystem TEXT,                 -- <spirit:onSystem> or <ipxact:onSystem>
    headerUserFile TEXT,           -- <spirit:headerUserFile> or <ipxact:headerUserFile>
    headerSystemFile TEXT,         -- <spirit:headerSystemFile> or <ipxact:headerSystemFile>
    monitorInterface TEXT,         -- <spirit:monitorInterface> or <ipxact:monitorInterface>
    bridgeInterface TEXT,          -- <spirit:bridgeInterface> or <ipxact:bridgeInterface>
    channelRef TEXT,               -- <spirit:channelRef> or <ipxact:channelRef>
    interconnectionRef TEXT,       -- <spirit:interconnectionRef> or <ipxact:interconnectionRef>
    designRules TEXT,              -- <spirit:designRules> or <ipxact:designRules>
    portMap TEXT,                  -- <spirit:portMap> or <ipxact:portMap>
    abstractionRef TEXT,           -- <spirit:abstractionRef> or <ipxact:abstractionRef>
    monitorType TEXT,              -- <spirit:monitorType> or <ipxact:monitorType>
    -- New attributes from example_registers.xml
    bitsInLau INTEGER,             -- <ipxact:bitsInLau>
    memoryMapRef TEXT,             -- <ipxact:memoryMapRef>
    FOREIGN KEY (metadata_id) REFERENCES metadata(id) ON DELETE CASCADE,
    CHECK (interfaceMode IN ('master', 'slave', 'system')),
    CHECK (endianness IN ('big', 'little')),
    CHECK (portAccessType IN ('read-write', 'read-only', 'write-only', 'writeOnce', 'read-writeOnce')),
    CHECK (monitorType IN ('status', 'control', 'debug', 'performance', 'error'))
);

-- Ports table - stores port information
CREATE TABLE ports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    metadata_id INTEGER NOT NULL,    -- Foreign key to metadata table
    name TEXT NOT NULL,             -- <spirit:name> or <ipxact:name>
    description TEXT,               -- <spirit:description> or <ipxact:description>
    direction TEXT NOT NULL,        -- <spirit:direction> or <ipxact:direction>
    isAddress BOOLEAN DEFAULT 0,    -- <spirit:isAddress> or <ipxact:isAddress>
    isData BOOLEAN DEFAULT 0,       -- <spirit:isData> or <ipxact:isData>
    width INTEGER DEFAULT 1,        -- <spirit:width> or <ipxact:width>
    isClock BOOLEAN DEFAULT 0,      -- <spirit:isClock> or <ipxact:isClock>
    isReset BOOLEAN DEFAULT 0,      -- <spirit:isReset> or <ipxact:isReset>
    defaultValue TEXT,             -- <spirit:defaultValue> or <ipxact:defaultValue>
    displayName TEXT,              -- <spirit:displayName> or <ipxact:displayName>
    isPresent TEXT,               -- <spirit:isPresent> or <ipxact:isPresent>
    driveConstraint TEXT,         -- <spirit:driveConstraint> or <ipxact:driveConstraint>
    timingConstraint TEXT,        -- <spirit:timingConstraint> or <ipxact:timingConstraint>
    loadConstraint TEXT,          -- <spirit:loadConstraint> or <ipxact:loadConstraint>
    longDescription TEXT,         -- <spirit:longDescription> or <ipxact:longDescription>
    groupName TEXT,              -- <spirit:group> or <ipxact:group>
    displayGroup TEXT,           -- <spirit:displayGroup> or <ipxact:displayGroup>
    physicalName TEXT,           -- <spirit:physicalName> or <ipxact:physicalName>
    clockDriver TEXT,            -- <spirit:clockDriver> or <ipxact:clockDriver>
    clockEdge TEXT,              -- <spirit:clockEdge> or <ipxact:clockEdge>
    clockFrequency INTEGER,      -- <spirit:clockFrequency> or <ipxact:clockFrequency>
    clockPeriod TEXT,            -- <spirit:clockPeriod> or <ipxact:clockPeriod>
    clockPulseOffset TEXT,       -- <spirit:clockPulseOffset> or <ipxact:clockPulseOffset>
    clockPulseValue TEXT,        -- <spirit:clockPulseValue> or <ipxact:clockPulseValue>
    clockWaveform TEXT,          -- <spirit:clockWaveform> or <ipxact:clockWaveform>
    signalName TEXT,             -- <spirit:signalName> or <ipxact:signalName>
    qualifier TEXT,              -- <spirit:qualifier> or <ipxact:qualifier>
    portAccessType TEXT,         -- <spirit:portAccessType> or <ipxact:portAccessType>
    portAccessHandle TEXT,       -- <spirit:portAccessHandle> or <ipxact:portAccessHandle>
    singleShot BOOLEAN DEFAULT 0, -- <spirit:singleShot> or <ipxact:singleShot>
    presenceCondition TEXT,      -- <spirit:presenceCondition> or <ipxact:presenceCondition>
    constraintSetId TEXT,        -- <spirit:constraintSetId> or <ipxact:constraintSetId>
    transactional BOOLEAN DEFAULT 0, -- <spirit:transactional> or <ipxact:transactional>
    levelType TEXT,              -- <spirit:levelType> or <ipxact:levelType>
    monitorType TEXT,            -- <spirit:monitorType> or <ipxact:monitorType>
    monitorConfig TEXT,          -- <spirit:monitorConfig> or <ipxact:monitorConfig>
    detectorType TEXT,           -- <spirit:detectorType> or <ipxact:detectorType>
    detectorConfig TEXT,         -- <spirit:detectorConfig> or <ipxact:detectorConfig>
    fsmState TEXT,              -- <spirit:fsmState> or <ipxact:fsmState>
    fsmTransition TEXT,         -- <spirit:fsmTransition> or <ipxact:fsmTransition>
    activeState TEXT,           -- <spirit:activeState> or <ipxact:activeState>
    synchronousTo TEXT,         -- <spirit:synchronousTo> or <ipxact:synchronousTo>
    powerDomain TEXT,           -- <spirit:powerDomain> or <ipxact:powerDomain>
    registeredBy TEXT,          -- <spirit:registeredBy> or <ipxact:registeredBy>
    timingValue INTEGER,        -- <spirit:timingValue> or <ipxact:timingValue>
    timingClockRef TEXT,        -- <spirit:timingClockRef> or <ipxact:timingClockRef>
    resetType TEXT,             -- <spirit:resetType> or <ipxact:resetType>
    resetPolarity TEXT,         -- <spirit:resetPolarity> or <ipxact:resetPolarity>
    resetTrigger TEXT,          -- <spirit:resetTrigger> or <ipxact:resetTrigger>
    resetDependency TEXT,       -- <spirit:resetDependency> or <ipxact:resetDependency>
    resetSequence TEXT,         -- <spirit:resetSequence> or <ipxact:resetSequence>
    FOREIGN KEY (metadata_id) REFERENCES metadata(id) ON DELETE CASCADE,
    UNIQUE(metadata_id, name),
    CHECK (direction IN ('in', 'out', 'inout')),
    CHECK (width > 0),
    CHECK (levelType IN ('high', 'low', 'either')),
    CHECK (monitorType IN ('status', 'control', 'debug', 'performance', 'error')),
    CHECK (detectorType IN ('edge', 'level', 'pattern', 'timeout')),
    CHECK (resetPolarity IN ('active-high', 'active-low'))
);

-- Parameters table - stores parameter information
CREATE TABLE parameters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    metadata_id INTEGER NOT NULL,    -- Foreign key to metadata table
    name TEXT NOT NULL,             -- <spirit:name> or <ipxact:name>
    type TEXT NOT NULL,             -- <spirit:type> or <ipxact:type>
    value TEXT NOT NULL,            -- <spirit:value> or <ipxact:value>
    description TEXT,               -- <spirit:description> or <ipxact:description>
    displayName TEXT,               -- <spirit:displayName> or <ipxact:displayName>
    minimumValue TEXT,              -- <spirit:minimumValue> or <ipxact:minimumValue>
    maximumValue TEXT,              -- <spirit:maximumValue> or <ipxact:maximumValue>
    choiceRef TEXT,                -- <spirit:choiceRef> or <ipxact:choiceRef>
    resolve TEXT,                  -- <spirit:resolve> or <ipxact:resolve>
    prompt TEXT,                   -- <spirit:prompt> or <ipxact:prompt>
    usageCount INTEGER,            -- <spirit:usageCount> or <ipxact:usageCount>
    format TEXT,                   -- <spirit:format> or <ipxact:format>
    arrayLeft TEXT,                -- <spirit:arrayLeft> or <ipxact:arrayLeft>
    arrayRight TEXT,               -- <spirit:arrayRight> or <ipxact:arrayRight>
    longDescription TEXT,          -- <spirit:longDescription> or <ipxact:longDescription>
    groupName TEXT,                -- <spirit:group> or <ipxact:group>
    displayGroup TEXT,             -- <spirit:displayGroup> or <ipxact:displayGroup>
    physicalName TEXT,             -- <spirit:physicalName> or <ipxact:physicalName>
    scope TEXT,                    -- <spirit:scope> or <ipxact:scope>
    lifeCycleStage TEXT,          -- <spirit:lifeCycleStage> or <ipxact:lifeCycleStage>
    dependency TEXT,               -- <spirit:dependency> or <ipxact:dependency>
    dataType TEXT,                 -- <spirit:dataType> or <ipxact:dataType>
    configGroups TEXT,             -- <spirit:configGroups> or <ipxact:configGroups>
    generateFile TEXT,             -- <spirit:generateFile> or <ipxact:generateFile>
    generatorRef TEXT,             -- <spirit:generatorRef> or <ipxact:generatorRef>
    instanceName TEXT,             -- <spirit:instanceName> or <ipxact:instanceName>
    leftRange TEXT,                -- <spirit:left> or <ipxact:left>
    rightRange TEXT,               -- <spirit:right> or <ipxact:right>
    presenceCondition TEXT,        -- <spirit:presenceCondition> or <ipxact:presenceCondition>
    moduleName TEXT,               -- <spirit:moduleName> or <ipxact:moduleName>
    moduleParameters TEXT,         -- <spirit:moduleParameters> or <ipxact:moduleParameters>
    designRules TEXT,             -- <spirit:designRules> or <ipxact:designRules>
    whiteboxElement TEXT,         -- <spirit:whiteboxElement> or <ipxact:whiteboxElement>
    abstractorRef TEXT,           -- <spirit:abstractorRef> or <ipxact:abstractorRef>
    designRef TEXT,               -- <spirit:designRef> or <ipxact:designRef>
    FOREIGN KEY (metadata_id) REFERENCES metadata(id) ON DELETE CASCADE,
    UNIQUE(metadata_id, name),
    CHECK (type IN ('integer', 'string', 'boolean', 'float', 'bit', 'bitVector')),
    CHECK (scope IN ('component', 'global', 'local')),
    CHECK (lifeCycleStage IN ('design', 'implementation', 'verification', 'validation', 'release')),
    CHECK (dataType IN ('string', 'integer', 'boolean', 'float', 'hex', 'binary')),
    CHECK (moduleName IN ('status', 'control', 'debug', 'performance', 'error'))
);

-- Vendor Extensions table - stores vendor-specific extensions
CREATE TABLE vendorExtensions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    metadata_id INTEGER NOT NULL,    -- Foreign key to metadata table
    vendorId TEXT NOT NULL,         -- <spirit:vendorId> or <ipxact:vendorId>
    key TEXT NOT NULL,              -- <spirit:key> or <ipxact:key>
    value TEXT NOT NULL,            -- <spirit:value> or <ipxact:value>
    FOREIGN KEY (metadata_id) REFERENCES metadata(id) ON DELETE CASCADE,
    UNIQUE(metadata_id, vendorId, key)
);

-- Enumerations table - stores enumerated values for fields
CREATE TABLE enumerations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    field_id INTEGER NOT NULL,
    name TEXT NOT NULL,             -- <spirit:name> or <ipxact:name>
    value TEXT NOT NULL,            -- <spirit:value> or <ipxact:value>
    description TEXT,               -- <spirit:description> or <ipxact:description>
    displayName TEXT,               -- <spirit:displayName> or <ipxact:displayName>
    usage TEXT,                     -- <spirit:usage> or <ipxact:usage>
    FOREIGN KEY (field_id) REFERENCES fields(id) ON DELETE CASCADE,
    UNIQUE(field_id, name)
);



-- Create indexes for better query performance
CREATE INDEX idx_metadata_vendor ON metadata(vendor);
CREATE INDEX idx_metadata_name ON metadata(name);
CREATE INDEX idx_metadata_library ON metadata(library);
CREATE INDEX idx_metadata_version ON metadata(version);

CREATE INDEX idx_memory_maps_metadata ON memoryMaps(metadata_id);
CREATE INDEX idx_memory_maps_name ON memoryMaps(name);

CREATE INDEX idx_address_blocks_memory_map ON addressBlocks(memoryMap_id);
CREATE INDEX idx_address_blocks_base_address ON addressBlocks(baseAddress);
CREATE INDEX idx_address_blocks_range ON addressBlocks(range);

CREATE INDEX idx_registers_address_block ON registers(addressBlock_id);
CREATE INDEX idx_registers_address_offset ON registers(addressOffset);

CREATE INDEX idx_fields_register ON fields(register_id);
CREATE INDEX idx_fields_bit_offset ON fields(bitOffset);

CREATE INDEX idx_bus_interfaces_metadata ON busInterfaces(metadata_id);
CREATE INDEX idx_bus_interfaces_bus_type ON busInterfaces(busType);

CREATE INDEX idx_ports_metadata ON ports(metadata_id);
CREATE INDEX idx_ports_direction ON ports(direction);

CREATE INDEX idx_parameters_metadata ON parameters(metadata_id);
CREATE INDEX idx_parameters_type ON parameters(type);

CREATE INDEX idx_vendor_extensions_metadata ON vendorExtensions(metadata_id);
CREATE INDEX idx_vendor_extensions_vendor ON vendorExtensions(vendorId);

CREATE INDEX idx_enumerations_field ON enumerations(field_id);

-- Create basic indexes for the most common columns
CREATE INDEX idx_fields_group_name ON fields(groupName);
CREATE INDEX idx_fields_display_group ON fields(displayGroup);
CREATE INDEX idx_fields_reset_type_ref ON fields(resetTypeRef);
CREATE INDEX idx_registers_group_name ON registers(groupName);
CREATE INDEX idx_registers_display_group ON registers(displayGroup);
CREATE INDEX idx_ports_group_name ON ports(groupName);
CREATE INDEX idx_parameters_scope ON parameters(scope);
CREATE INDEX idx_parameters_data_type ON parameters(dataType);

 